#
#--
# Wordlist - A Ruby library for generating and working with word lists.
#
# Copyright (c) 2009 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#++
#

require 'wordlist/builder'

require 'spidr'

module Wordlist
  module Builders
    class Website < Builder

      # Host to spider
      attr_accessor :host

      def initialize(path,options={},&block)
        @host = options[:host]

        super(path,&block)
      end

      def build!(&block)
        Spidr.host(@host) do |spidr|
          spidr.every_page do |page|
            if page.html?
              page.doc.search('h1|h2|h3|h4|h5|p|span').each do |element|
                parse(element.inner_text)
              end
            end
          end
        end

        super(&block)
      end

    end
  end
end