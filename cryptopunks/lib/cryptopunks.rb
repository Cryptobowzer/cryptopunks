## 3rd party
require 'pixelart/base'
require 'csvreader'



## extra stdlibs
require 'digest'     ## move/add to pixelart upstream - why? why not?
require 'optparse'



## our own code
require 'cryptopunks/version'    # note: let version always go first

## forward define superclass for image
module Cryptopunks
  class Image < Pixelart::Image; end
end


require 'cryptopunks/attributes'
require 'cryptopunks/structs'
require 'cryptopunks/composite'
require 'cryptopunks/dataset'

require 'cryptopunks/colors'
require 'cryptopunks/image'

require 'cryptopunks/generator'

###
## add convenience pre-configurated generatored with build-in spritesheet (see config)

module Cryptopunks

  def self.generator
    @generator ||= Generator.new(  "#{root}/config/spritesheet.png",
                                   "#{root}/config/spritesheet.csv" )
  end

  class Image
     def self.generate( *values )
       img = Cryptopunks.generator.generate( *values )
       ## note: unwrap inner image before passing on to c'tor (requires ChunkyPNG image for now)
       new( img.image )
     end
  end # class Image
end #  module Cryptopunks






module Cryptopunks
class Tool
  def run( args )
    opts = { zoom: 1,
             outdir: '.',
             file:  './punks.png',
             offset: 0,
           }

    parser = OptionParser.new do |cmd|
      cmd.banner = "Usage: punk (or cryptopunk) [options] IDs"

      cmd.separator "  Mint punk characters from composite (#{opts[:file]}) - for IDs use 0 to 9999"
      cmd.separator ""
      cmd.separator "  Options:"

      cmd.on("-z", "--zoom=ZOOM", "Zoom factor x2, x4, x8, etc. (default: #{opts[:zoom]})", Integer ) do |zoom|
        opts[:zoom] = zoom
      end

      cmd.on("-d", "--dir=DIR", "Output directory (default: #{opts[:outdir]})", String ) do |outdir|
        opts[:outdir] = outdir
      end

      cmd.on("-f", "--file=FILE", "True Official Genuine CryptoPunks™ composite image (default: #{opts[:file]})", String ) do |file|
        opts[:file] = file
      end

      cmd.on("--offset=NUM", "Start counting at offset (default: #{opts[:offset]})", Integer ) do |offset|
        opts[:offset] = offset
      end

      cmd.on("-h", "--help", "Prints this help") do
        puts cmd
        exit
      end
    end

    parser.parse!( args )

    puts "opts:"
    pp opts

    puts "==> reading >#{opts[:file]}<..."
    punks = Image::Composite.read( opts[:file] )


    puts "    setting zoom to #{opts[:zoom]}x"   if opts[:zoom] != 1

    ## make sure outdir exits (default is current working dir e.g. .)
    FileUtils.mkdir_p( opts[:outdir] )  unless Dir.exist?( opts[:outdir] )

    args.each_with_index do |arg,index|
      punk_index = arg.to_i

      punk = punks[ punk_index ]

      punk_name = "punk-" + "%04d" % (punk_index + opts[:offset])

      ##  if zoom - add x2,x4 or such
      if opts[:zoom] != 1
        punk = punk.zoom( opts[:zoom] )
        punk_name << "x#{opts[:zoom]}"
      end

      path  = "#{opts[:outdir]}/#{punk_name}.png"
      puts "==> (#{index+1}/#{args.size}) minting punk ##{punk_index+opts[:offset]}; writing to >#{path}<..."

      punk.save( path )
    end

    puts "done"
  end  ## method run
end # class Tool


def self.main( args=ARGV )
  Tool.new.run( args )
end
end ## module Cryptopunks




### add more built-in (load on demand) design series / collections
DESIGNS_ORIGINAL = Cryptopunks::DesignSeries.new( "#{Cryptopunks.root}/config/original" )
DESIGNS_MORE     = Cryptopunks::DesignSeries.new( "#{Cryptopunks.root}/config/more" )

## all designs in one collections
DESIGNS = {}.merge( DESIGNS_ORIGINAL.to_h,
                    DESIGNS_MORE.to_h )




### add some convenience shortcuts
CryptoPunks = Cryptopunks
Punks       = Cryptopunks




###
# note: for convenience auto include Pixelart namespace!!! - why? why not?
include Pixelart



puts Cryptopunks.banner    # say hello
