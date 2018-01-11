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

require 'aws-sdk'
require 'ruby_aem_aws/component/author_dispatcher'

module RubyAemAws
  module Component
    #
    class AuthorDispatcher
      # TODO
      #
      # @param client TODO
      # @param stack_prefix TODO
      # @return new RubyAemAws::FullSet::AuthorDispatcher
      def initialize(client, stack_prefix)
        @client = client
        @stack_prefix = stack_prefix
      end

      def healthy?
        has_instance = false
        instances = @client.instances({filters: [
                                  {name: 'tag:StackPrefix', values: [@stack_prefix]},
                                  {name: 'tag:Component', values: ['author-dispatcher']},
                                  {name: 'tag:Name', values: ['AuthorDispatcher']},
                                 ]})
        instances.each do |i|
          puts('AuthorDispatcher instance: %s' % i.id)
          has_instance = true
          return false if i.state.name != 'running'
        end
        has_instance
      end

      def get_all_instances
      end

      def get_random_instance
      end

      def get_num_of_instances
      end

      def terminate_all_instances
      end

      def terminate_random_instance
      end

      def wait_until_healthy
      end

      def to_s
        'AuthorDispatcher(%s)' % @client
      end
    end
  end
end
