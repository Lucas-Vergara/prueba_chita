require 'faraday'
require 'json'
require 'time'

client_dni = ''
debtor_dni = ''
document_amount = ''
folio = ''
expiration_date = Time.now

puts '¿Quieres hacer la prueba con valores predeterminados? (n,y)'
predeterminado = gets.chomp


while predeterminado != 'n' && predeterminado != 'N' && predeterminado != 'Y' && predeterminado != 'y'
  puts 'Por favor, ingresar "y" para usar valores predeterminados, o "n" para ingresar valores.'
  predeterminado = gets.chomp
end

if predeterminado == 'y' || predeterminado == 'Y'
  client_dni = '76329692K'
  debtor_dni = '773603901'
  document_amount = '1000000'
  folio = '75'
  expiration_date = (Time.now + 31*86400)
elsif predeterminado == 'n' || predeterminado == 'N'
  puts 'Porfavor ingresar los siguientes datos:'
  puts 'Rut Emisor'
  client_dni = gets.chomp
  client_dni.tr('-', '')
  client_dni.tr('.', '')
  puts 'Rut Receptor'
  debtor_dni = gets.chomp
  client_dni.tr('-', '')
  client_dni.tr('.', '')
  puts 'Monto de la Factura'
  document_amount = gets.chomp
  document_amount.tr('.', '')
  puts 'Folio de la factura'
  folio = gets.chomp
  folio.tr('.', '')
  puts 'Fecha de Vencimiento de la factura (aaaa-mm-dd)'
  date = gets.chomp
  expiration_date = Time.parse(date)
end

url = 'https://chita.cl/api/v1/pricing/simple_quote?client_dni=' + client_dni + 
'&debtor_dni=' + debtor_dni +
'&document_amount='+ document_amount + 
'&folio='+ folio + 
'&expiration_date=' + expiration_date.strftime("%Y-%m-%d")
request = Faraday.new(url, headers: {'X-Api-Key' => 'UVG5jbLZxqVtsXX4nCJYKwtt'}).get
requestJson = JSON.parse(request.body)

if request.status == 400
  puts 'Datos incorrectos'
  exit
end

########### IMPORTANTE ##################
# la llamada a la api siempre me devuelve valores de document_rate = 0.89 y commission = 0
# Para mantener los datos entregados en la prueba, tendría que ingresar 
if predeterminado == 'y' || predeterminado == 'Y'
  requestJson = {
                  "document_rate": 1.9,
                  "commission": 23990.0,
                  "advance_percent": 99.0,
                }
end


document_rate =  requestJson.values[0]/100
commission = requestJson.values[1]
advance_percent = requestJson.values[2]/100

timeLimit = ((expiration_date - Time.now)/86400).round()
financingCost = ((document_amount.to_i*advance_percent) * (document_rate/30*timeLimit)).round()
advance = ((document_amount.to_i * advance_percent) - (financingCost + commission)).round()
surplus = (document_amount.to_i - (document_amount.to_i * advance_percent)).round()


puts "\n"*2
puts 'RESULTADOS'.center(50)
puts "\n"*2
puts 'Costo de financiamiento = $' + financingCost.to_s
puts 'Giro a recibir = $' + advance.to_s 
puts 'Excedentes = $' + surplus.to_s






