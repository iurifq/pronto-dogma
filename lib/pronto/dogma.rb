require 'pronto/dogma/version'
require 'pronto'

module Pronto::Dogma
  class Runner < Pronto::Runner
    ELIXIR_EXTENSIONS = %w(.ex .exs).freeze

    def run
      return [] unless dogma_output_pathname.exist?
      elixir_patches
        .select { |patch| patch.delta.status != :deleted }
        .flat_map { |patch| affected_lines(patch) }
    end

    def affected_lines(patch)
      candidate_lines = patch.lines.select { |line| line.addition? }
      candidate_lines.reduce([]) do |accum, line|
        affected_line = dogma_lines.find do |dline|
          patch.repo.path.join(dline.path) == patch.new_file_full_path &&
            dline.lineno == line.new_lineno
        end

        if affected_line
          accum << new_message(line, affected_line)
        else
          accum
        end
      end
    end

    def new_message(line, dline)
      Pronto::Message.new(dline.path, line, :warning, dline.error)
    end

    def elixir_patches
      @patches.select do |patch|
        ELIXIR_EXTENSIONS.member?(File.extname(patch.new_file_full_path))
      end
    end

    def dogma_output_pathname
      @dogma_output_path ||= Pathname.new(
        ENV["PRONTO_DOGMA_OUTPUT"] || "dogma.out"
      )
    end

    def dogma_lines
      @dogma_lines ||= matching_lines(
        dogma_output_pathname,
        /(?<path>.+\.[a-z]{2,3}):(?<lineno>[0-9]+):[0-9]+: [A-Z]: (?<error_msg>.+)/
      )
    end

    private

    def matching_lines(pathname, line_regex)
      pathname.readlines.reduce([]) do |accum, line|
        if match = line.match(line_regex)
          accum << OpenStruct.new(
            path: match[:path],
            lineno: match[:lineno].to_i,
            error: match[:error_msg]
          )
        else
          accum
        end
      end
    end
  end
end
