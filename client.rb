require 'socket'
require 'openssl'
#encoding: cp1251

def prime?(n,g)
  d = n - 1
  s = 0
  while d % 2 == 0
    d /= 2
    s += 1
  end
  g.times do
    a = 2 + rand(n-4)
    x = OpenSSL::BN::new(a.to_s).mod_exp(d,n) #x = (a**d) % n
    next if x == 1 or x == n-1
    for r in (1 .. s-1)
      x = x.mod_exp(2,n)  #x = (x**2) % n
      return false if x == 1
      break if x == n-1
    end
    return false if x != n-1
  end
  true  # probably
end

def generate_private_key(public_key)
  public = public_key - 1

  while true
    private_a = rand(2..public)
    arr = gcd(public, private_a)
    break if arr[0] == 1
  end

  if arr[2]>0
    private_b = arr[2]
  else
    private_b = arr[2] + public
  end
  [private_a, private_b]
end

def gcd(a, b)
  u = [a, 1, 0]
  v = [b, 0, 1]
  while  v[0]!=0
    q = u[0]/v[0]
    t = [u[0]%v[0], u[1]-q*v[1], u[2]-q*v[2]]
    u = v
    v = t
  end
  u
end

def generate_public_key(bits)
  pub_key = rand(2**bits..2**(bits+1))
  until prime?(pub_key, 20)
    pub_key = rand(2**bits..2**(bits+1))
  end
  pub_key
end


file_name = ARGV[0].chomp
host = ARGV[1]
port = ARGV[2]
bits = ARGV[3].to_i
puts 'client-bits', bits

public_key = generate_public_key(bits)
puts 'client-public', public_key
private_key = generate_private_key(public_key)
puts 'client-private', private_key[0], private_key[1]

socket = TCPSocket.open(host, port)

socket.puts(File.basename(file_name))
socket.puts(public_key)
socket.puts(bits)


File.open((file_name), 'rb') do |file|
  while chunk = file.read(bits/8)
    num = chunk.bytes.inject {|a, b| (a<<8) + b}
    num = OpenSSL::BN::new(num.to_s).mod_exp(private_key[0],public_key)
    socket.puts(num)
  end
end
puts 'клиент шаг 1 закончен'

while chunk = socket.read()
  chunk = OpenSSL::BN::new(chunk).mod_exp(private_key[1],public_key)
  socket.puts(chunk)
end
puts 'клиент шаг 3 закончен'
#закрытие соединения
socket.close


