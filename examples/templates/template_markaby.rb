require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  engine :Markaby

  helper :markaby

  def index
    %{ #{a('Home',:/)} | #{a(:internal)} | #{a(:external)} }
  end

  def internal *args
    options = {:place => :internal, :action => 'internal',
      :args => args, :request => request, :this => self}
    mab options do
      html do
        head do
          title "Template::Markaby #@place"
        end
        body do
          h1 "The #@place Template for Markaby"
          a("Home", :href => R(@this))
          p do
            text "Here you can pass some stuff if you like, parameters are just passed like this:"
            br
            a("#@place/one", :href => r(@this, @place, :one))
            br
            a("#@place/one/two/three", :href => r(@this, @place, :one, :two, :three))
            br
            a("#@place/one?foo=bar", :href => r(@this, @place, :one, :foo => :bar))
            br
          end
          div do
            text "The arguments you have passed to this action are:"
            if @args.empty?
              text "none"
            else
              args.each do |arg|
                span arg
              end
            end
          end
          div @request.params.inspect
        end
      end
    end.to_s
  end

  def external *args
    @args = args
    @request = request
    @place = :external
  end
end

Ramaze.start :file => __FILE__
