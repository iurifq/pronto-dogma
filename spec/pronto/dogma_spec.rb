require 'spec_helper'

describe Pronto::Dogma do
  it 'has a version number' do
    expect(Pronto::Dogma::VERSION).not_to be nil
  end

  describe Pronto::Dogma::Runner do
    let(:repo) {
      double(:repo,
             path: Pathname.new("."),
             blame: double(:blame, :[] => commit))
    }
    let(:commit) { "abc123" }
    let(:patches) { Pronto::Git::Patches.new(repo, commit, patches_array) }

    subject { described_class.new(patches) }

    describe "#elixir_patches" do
      let(:patches_array) { [
        double(:ex_patch, delta: double(new_file: {path: "spec/fixtures/test.ex"})),
        double(:ruby_patch, delta: double(new_file: {path: "spec/spec_helper.rb"})),
        double(:exs_patch, delta: double(new_file: {path: "spec/fixtures/test.exs"})),
      ]}

      it 'selects files with .ex and .exs extensions' do
        ex_patch, exs_patch = subject.elixir_patches
        expect(subject.elixir_patches.count).to eq 2
        expect(File.extname(ex_patch.new_file_full_path)).to eq ".ex"
        expect(File.extname(exs_patch.new_file_full_path)).to eq ".exs"
      end
    end

    describe "#run" do
      let(:patches_array) { [
        double(:patch1,
               delta: double(
                 :delta1,
                 status: :deleted,
                 new_file: {path: "spec/fixtures/deleted.ex"})),
        double(:patch2,
               delta: double(
                 :delta2,
                 status: :added,
                 new_file: {path: "spec/fixtures/test.exs"}),
               hunks: [
                 double(:hunk,
                        lines: [double(:line, addition?: true, new_lineno: 2)])]
              )
      ]}

      context 'when dogma output does not exist' do
        it 'returns []' do
          expect(subject.run).to eq []
        end
      end

      context 'when dogma output exists' do
        before do
          ENV['PRONTO_DOGMA_OUTPUT'] = "spec/fixtures/dogma.out"
        end

        it 'returns messages for the indicated dogma lines' do
          messages = subject.run
          message = messages.first
          expect(message.path).to eq("spec/fixtures/test.exs")
          expect(message.level).to eq(:warning)
          expect(message.msg).to eq("Line length should not exceed 80 chars (was 90).")
          expect(message.commit_sha).to eq(commit)
          expect(messages.count).to eq(1)
        end
      end
    end

    describe "#dogma_lines" do
      let(:patches_array) { [] }

      before do
        allow(ENV).to receive(:[]).with('PRONTO_DOGMA_OUTPUT') {
          "spec/fixtures/dogma.out"
        }
      end

      it 'parses lines correctly' do
        affected_lines = subject.dogma_lines
        expect(affected_lines.count).to eq 317
        expect(affected_lines).to include(
          OpenStruct.new(lineno: 43, path: "test/users_test.exs", error: "Comparison to a boolean is pointless")
        )
      end
    end
  end
end
