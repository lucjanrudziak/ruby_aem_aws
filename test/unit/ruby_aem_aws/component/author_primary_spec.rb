# Copyright 2018 Shine Solutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../../spec_helper'
require_relative 'examples/check_methods_exist'
require_relative '../../../../lib/ruby_aem_aws/component/author'

author_primary = RubyAemAws::Component::AuthorPrimary.new(nil, nil, nil)

describe author_primary do
  it_behaves_like 'a health flagged component'
end

describe 'AuthorPrimary' do
  before do
    @instance_component = RubyAemAws::Component::AuthorPrimary::EC2_COMPONENT
    @instance_name = RubyAemAws::Component::AuthorPrimary::EC2_NAME
    @instance_filter = [
      { StackPrefix: TEST_STACK_PREFIX },
      { Component: @instance_component },
      { Name: @instance_name }
    ].freeze
    @instance_1_id = 'i-00525b1a281aee5b9'.freeze
    @instance_2_id = 'i-00525b1a281aee5b7'.freeze

    @mock_ec2 = mock_ec2

    @metric_1_name = 'A test metric'
    @metric_2_name = 'Unmocked'

    @mock_cloud_watch = mock_cloud_watch

    @instances = []
  end

  it '.healthy? verifies EC2 running instance' do
    add_instance(@mock_ec2, @instances, @instance_filter, @instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(mock_author_primary.healthy?).to equal true
  end

  it '.healthy? verifies no EC2 running instance' do
    expect(mock_author_primary.healthy?).to equal false
  end

  it '.metric? verifies metric exists' do
    add_instance(@mock_ec2, @instances, @instance_filter, @instance_1_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id])

    expect(mock_author_primary.metric?(@metric_1_name)).to equal true
  end

  it '.metric? verifies metric does not exist' do
    add_instance(@mock_ec2, @instances, @instance_filter, @instance_1_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id])

    expect(mock_author_primary.metric?(@metric_2_name)).to equal false
  end

  it '.metric_instances returns all instances with metric' do
    add_instance(@mock_ec2, @instances, @instance_filter, @instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@mock_ec2, @instances, @instance_filter, @instance_2_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id, @instance_2_id])

    expect(mock_author_primary.metric_instances(@metric_1_name).length).to be == mock_author_primary.get_all_instances.length
  end

  it '.metric_instances returns only instances with metric' do
    add_instance(@mock_ec2, @instances, @instance_filter, @instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@mock_ec2, @instances, @instance_filter, @instance_2_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id])
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_2_name, [@instance_2_id])

    expect(mock_author_primary.metric_instances(@metric_1_name).length).to be < mock_author_primary.get_all_instances.length
  end

  private

  def mock_author_primary
    author = RubyAemAws::Component::Author.new(TEST_STACK_PREFIX, @mock_ec2, @mock_cloud_watch)
    author.author_primary
  end
end
