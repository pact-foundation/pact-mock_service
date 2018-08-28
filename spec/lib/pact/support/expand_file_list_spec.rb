require 'pact/support/expand_file_list'

module Pact
  module Support
    module ExpandFileList
      describe "#call" do

        subject { ExpandFileList.call(file_list) }

        context "with a list of json files" do
          let(:file_list) { ["file1.json", "file2.json"] }

          it "returns the list" do
            expect(subject).to eq file_list
          end
        end

        context "with a list of json files that contains a windows path" do
          let(:file_list) { ["c:\\foo\\file1.json"] }

          it "returns the list in Unix format" do
            expect(subject).to eq ["c:/foo/file1.json"]
          end
        end

        context "with a directory" do
          let(:file_list) { ["spec/support/"] }

          it "returns a list of the json files inside" do
            expect(subject.size).to be > 1

            subject.each do | path |
              expect(path).to start_with("spec/support")
              expect(path).to end_with(".json")
            end
          end
        end

        context "with a glob" do
          let(:file_list) { ["spec/support/*.json"] }

          it "returns a list of the json files inside" do
            expect(subject.size).to be > 1

            subject.each do | path |
              expect(path).to start_with("spec/support")
              expect(path).to end_with(".json")
            end
          end
        end
      end
    end
  end
end
