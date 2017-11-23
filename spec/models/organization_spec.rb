require 'rails_helper'

describe Organization do

  let(:organization) { build(:organization) }

  it { should respond_to(:generalitat_catalunya?) }
  it { should respond_to(:cnmc?) }
  it { should respond_to(:europe_union?) }
  it { should respond_to(:others?) }

  it { should respond_to(:range_1?) }
  it { should respond_to(:range_2?) }
  it { should respond_to(:range_3?) }
  it { should respond_to(:range_4?) }

  it { should respond_to(:federation?) }
  it { should respond_to(:association?) }
  it { should respond_to(:lobby?) }

  it "Should be valid" do
    expect(organization).to be_valid
  end

  it "Should not be valid when inscription_reference already exists" do
    create(:organization, inscription_reference: "XYZ")
    another_organization = build(:organization, inscription_reference: "XYZ")

    expect(another_organization).not_to be_valid
  end

  it "should not be valid whitout name" do
    organization.name = nil

    expect(organization).not_to be_valid
  end

  it "should not be valid whitout user" do
    organization.user = nil

    expect(organization).not_to be_valid
  end

  it "should not be valid with denied_public_data" do
    organization.denied_public_data = true

    expect(organization).not_to be_valid
  end

  it "should not be valid with denied_public_events" do
    organization.denied_public_events = true

    expect(organization).not_to be_valid
  end

  describe "#fullname" do
    it "Should return first_name and last_name when they are defined" do
      organization.name = "Name"
      organization.first_name = "FirstName"
      organization.last_name = "LastName"

      expect(organization.fullname).to eq "FirstName LastName"
    end

    it "Should return name when first and last names are not defined " do
      organization.name = "Company Name"

      expect(organization.fullname).to eq "Company Name"
    end
  end

end
