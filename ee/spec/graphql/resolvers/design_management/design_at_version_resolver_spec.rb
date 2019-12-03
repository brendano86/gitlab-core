# frozen_string_literal: true

require "spec_helper"

describe Resolvers::DesignManagement::DesignAtVersionResolver do
  include GraphqlHelpers
  include DesignManagementTestHelpers

  set(:issue) { create(:issue) }
  set(:project) { issue.project }
  set(:user) { create(:user) }
  set(:design_a) { create(:design, issue: issue) }
  set(:version_a) { create(:design_version, issue: issue, created_designs: [design_a]) }
  let(:current_user) { user }
  let(:object) { issue.design_collection }
  let(:global_id) { GitlabSchema.id_from_object(design_at_version).to_s }

  let(:design_at_version) { ::DesignManagement::DesignAtVersion.new(design: design_a, version: version_a) }

  before do
    enable_design_management
    project.add_developer(user)
  end

  describe "#resolve" do
    context "when the user cannot see designs" do
      let(:current_user) { create(:user) }

      it "returns nothing" do
        expect(resolve_design).to be_nil
      end
    end

    it "returns the specified design" do
      expect(resolve_design).to eq(design_at_version)
    end

    context 'the ID belongs to a design on another issue' do
      let(:other_dav) do
        issue = create(:issue, project: project)
        design = create(:design, issue: issue)
        version = create(:design_version, issue: issue, created_designs: [design])
        ::DesignManagement::DesignAtVersion.new(design: design, version: version)
      end

      let(:global_id) { GitlabSchema.id_from_object(other_dav).to_s }

      it "returns nothing" do
        expect(resolve_design).to be_nil
      end

      context "the current object does not constrain the issue" do
        let(:object) { nil }

        it "returns the object" do
          expect(resolve_design).to eq(other_dav)
        end
      end
    end
  end

  private

  def resolve_design
    args = { id: global_id }
    ctx = { current_user: current_user }
    resolve(described_class, obj: object, args: args, ctx: ctx)
  end
end
