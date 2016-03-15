require "./spec_helper"

module Biplane
  describe ChildCollection do
    other = json_fixture(Plugin)
    other.name = "other"
    array = [
      json_fixture(Plugin),
      other,
    ]

    collect = ChildCollection.new("name", array)

    first_diff = yaml_fixture(PluginConfig)
    second_diff = yaml_fixture(PluginConfig)

    # modified
    second_diff.name = "other"
    second_diff.attributes = nil
    for_diff = [
      first_diff,
      second_diff,
    ]

    it "can return the id key" do
      collect.id_key.should eq "name"
    end

    it "can return the keys defined by the key property" do
      collect.keys.should eq(["acl", "other"])
    end

    it "can lookup a specific item by key" do
      collect.lookup("other").should eq(other)
    end

    it "can check equality with an array" do
      collect.should eq(array)
    end

    it "can serialize the collection" do
      collect.serialize.should eq([
        {"name" => "acl", "attributes" => {"config" => {"whitelist" => ["docs-auth", "google-auth"]}}},
        {"name" => "other", "attributes" => {"config" => {"whitelist" => ["docs-auth", "google-auth"]}}},
      ])
    end

    it "can diff with an array" do
      collect.diff(for_diff).should eq({
        "other": {"attributes" => {
          "config" => Diff.new(nil, {"whitelist" => ["docs-auth", "google-auth"]}),
        }},
      })
    end

    it "can diff with another ChildCollection" do
      other_collect = ChildCollection.new("name", for_diff)

      collect.diff(other_collect).should eq({
        "other": {"attributes" => {
          "config" => Diff.new(nil, {"whitelist" => ["docs-auth", "google-auth"]}),
        }},
      })
    end
  end
end