require 'google/cloud/dns'
require 'pry'

@records = {}
@templates = {}

def vpc(_, __); end

def template(name, &body)
  @templates[name] = body
end

def include_template(name, options = @context)
  t = @templates[name]
  if t.nil?
    raise 'unknown template'
  end

  @context = OpenStruct.new(options)
  def context
    @context
  end
  t[]
end

def rrset(k, type, &body)
  @rec = {
      key: k,
      type: type
    }
  def ttl(n)
    @rec[:ttl] = n
  end
  def resource_records(to)
    @rec[:to] = to
  end
  body[]

  @records[(k + "-" + type).to_sym] = @rec.to_hash
end

@create = []
@update = []
@destroy = []
def create(r)
  @create << r
end
def update(x)
  @update << x
end
def destroy(r)
  @destroy << r
end

def show_create
  puts "#{@create.length} new records"
  @create.each do |r|
    puts "\t++ #{r[:key]}: type: #{r[:type]} ttl: #{r[:ttl]} to:#{r[:to]}"
  end
end
def show_update
  puts "#{@update.length} records update"
  @update.each do |x|
    new = x[:new]
    old = x[:old]
    raise "update condition conflict" if new[:key] != old[:key]
    diff = []
    [:type, :ttl, :to].each do |k|
      diff << k if new[k] != old[k]
    end
    raise "update: diff" if diff == []
    puts "\tdd #{new[:key]}: type: #{new[:type]} ttl: #{new[:ttl]} to:#{new[:to]}"
    diff.each do |k|
      puts "\t\told #{k}: #{old[k]}"
    end
  end
end
def show_destroy
  puts "#{@destroy.length} records update"
  @destroy.each do |r|
    puts "\t-- #{r[:key]}: type: #{r[:type]} ttl: #{r[:ttl]} to:#{r[:to]}"
  end
end
def show
  show_create
  show_update
  show_destroy
end

def execute_create
  @create.each do |r|
    puts "adding #{r[:key]}"
    @zone.add r[:key], r[:type], r[:ttl], r[:to]
    puts "added #{r[:key]}"
  end
end
def execute_update
  @update.each do |x|
    r = x[:new]
    puts "updating #{r[:key]}"
    @zone.replace r[:key], r[:type], r[:ttl], r[:to]
    puts "updated #{r[:key]}"
  end
end
def execute_destroy
  @destroy.each do |r|
    puts "deleting #{r[:key]}"
    @zone.remove r[:key], r[:type]
    puts "deleted #{r[:key]}"
  end
end
def execute
  show

  puts "press enter to continue"
  gets
  puts "start"
  execute_create
  execute_update
  execute_destroy
end

def hosted_zone(z, &body)
  dns = Google::Cloud::Dns.new
  zones = dns.zones
  zones.each do |zone|
    if z == zone.dns
      @zone = zone
      puts "start #{z}"

      body[]
      real_records = {}
      zone.records.select { |r| r.type == 'A' || r.type == 'CNAME' }.each do |r|
        real_records[(r.name + "-" + r.type).to_sym] = {
          key: r.name,
          type: r.type,
          ttl: r.ttl,
          to: r.data[0],
        }
      end
      @records.each do |k, v|
        real = real_records[k]
        if real.nil?
          create(v)
        else
          if real != v
            update({new: v, old: real})
          end
          real[:done] = true
        end
      end
      real_records.each do |k, v|
        if v[:done] != true
          destroy(v)
        end
      end
      execute
    end
  end
end

load '../../aws/route53/iii.dark-kuins.net.route'
