require 'socket'
require 'openssl'
#encoding: cp1251

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


server = TCPServer.open(5456)  # Socket to listen on port 2000
client = server.accept
file_name = 'copy'+client.gets.chomp
public_key = client.gets.chomp.to_i
bits = client.gets.chomp.to_i

private_key = generate_private_key(public_key)

#puts 'сервер', private_key, private_key[0], private_key
#puts 'сервер', bits
while chunk = client.read()
  puts chunk
  chunk = OpenSSL::BN::new(chunk.to_s).mod_exp(private_key[0],public_key)
  client.puts(chunk)
end
puts 'сервер шаг 2 закончен'
File.open(file_name, 'w') do |file|
  while chunk = client.read()
    chunk = OpenSSL::BN::new(chunk.to_s).mod_exp(private_key[1],public_key)
    file.puts(chunk)
  end
end
puts 'сервер шаг 4 закончен'

#закрытие соединения
client.close
server.close


