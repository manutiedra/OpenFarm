# frozen_string_literal: true

require 'spec_helper'
require 'openfarm_errors'

describe GardenCrops::UpdateGardenCrop do
  let(:ugc) { GardenCrops::UpdateGardenCrop }

  let(:user) { FactoryBot.create(:user) }
  let(:garden) { FactoryBot.create(:garden, user: user) }
  let(:garden_crop) { FactoryBot.create(:garden_crop, garden: garden) }

  let(:params) do
    { user: user,
      garden_crop: garden_crop,
      attributes: { stage: 'update',
                    sowed: Faker::Date.between(from: 2.days.ago, to: Date.today),
                    quantity: rand(100) } }
  end

  it 'requires fields' do
    errors = ugc.run({}).errors.message_list
    expect(errors).to include('Garden Crop is required')
    expect(errors).to include('User is required')
  end

  it 'catches updating gardens not owned by user' do
    other_garden_crop = FactoryBot.create(:garden_crop)
    params[:garden_crop] = other_garden_crop
    results = ugc.run(params)
    message = results.errors.message_list.first
    expect(message).to include('only update crops that are in your gardens.')
  end

  it 'updates valid garden crops' do
    result = ugc.run(params).result
    expect(result).to be_a(GardenCrop)
    expect(result.valid?).to be(true)
  end
end
