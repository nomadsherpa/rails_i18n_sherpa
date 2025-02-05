# frozen_string_literal: true

require "./lib/user_interface"

describe UserInterface do
  describe ".fetch_translations" do
    let(:translations_from_the_user) do
      <<~TRANSLATIONS
        key: key1.value
        en: English1
        fr: French
        key: key2.value
        en: English2
        fr: French
      TRANSLATIONS
    end

    before do
      ENV["EDITOR"] = <<~EDITOR.strip
        perl -e '
          open my $fh, ">", $ARGV[0];
          print $fh "#{translations_from_the_user}";
          close $fh;
        '
      EDITOR
    end

    it "returns the expected data structure" do
      translations = described_class.fetch_translations

      expect(translations).to be_an(Array)
      expect(translations[0]["key"]).to eq("key1.value")
      expect(translations[0]["en"]).to eq("English1")

      expect(translations[1]["key"]).to eq("key2.value")
      expect(translations[1]["en"]).to eq("English2")
    end

    it "removes the temp file" do
      described_class.fetch_translations

      expect(File).not_to exist(described_class::TEMP_FILE_PATH)
    end

    describe "???" do
      let(:translations_from_the_user) do
        <<~TRANSLATIONS
          key: key1.value
          en: Warning: Keep right
        TRANSLATIONS
      end

      it "returns the expected data structure" do
        translations = described_class.fetch_translations

        expect(translations).to be_an(Array)
        expect(translations[0]["key"]).to eq("key1.value")
        expect(translations[0]["en"]).to eq("Warning: Keep right")
      end
    end

    describe "multiline support" do
      let(:translations_from_the_user) do
        <<~TRANSLATIONS
          key: key1.value
          en: Line 1
          Line 2
          fr: French

          key: key2.value
          en:
          Line 1
          Line 2
          fr: French
        TRANSLATIONS
      end

      it "returns the expected data structure" do
        translations = described_class.fetch_translations

        expect(translations).to be_an(Array)
        expect(translations[0]["key"]).to eq("key1.value")
        expect(translations[0]["en"]).to eq("Line 1\nLine 2")

        expect(translations[1]["key"]).to eq("key2.value")
        expect(translations[1]["en"]).to eq("Line 1\nLine 2")
      end
    end
  end
end
