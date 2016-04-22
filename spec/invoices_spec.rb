# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'invoices' do
  before do

    @payload = {
      :paid             => 0,
      :type             => :net,
      :account_no       => "11 1100 1100 1100 1100 1100 1100",
      :issue_date       => Date.new(2011, 10, 20),
      :sale_date        => Date.new(2011, 10, 21),
      :sale_date_format => :daily,
      :due_date         => Date.new(2011, 11, 20),
      :payment_type     => :wire,
      :designation_type => "BPO",
      :gios             => false,
      :number           => nil,
      :customer_id      => 'Joe Black',
      :customer         => {
        :id      => 'Joe Black',
        :name    => "joe",
        :nip     => "333-333-33-33",
        :street  => "Marszalkowska",
        :zipcode => "12-345",
        :city    => "Warszawa",
        :email   => "joe@example.org",
        :phone   => "123456789"
      },
      :items => [{
        :vat_rate => 7,
        :quantity => 10,
        :price    => 100,
        :name     => "Development",
        :unit     => "hour",
        :vat_type => :percent
      }]
    }

    @body = {
      "Zaplacono"                => 0,
      "LiczOd"                   => "NET",
      "NumerKontaBankowego"      => "11110011001100110011001100",
      "DataWystawienia"          => "2011-10-20",
      "DataSprzedazy"            => "2011-10-21",
      "FormatDatySprzedazy"      => "DZN",
      "TerminPlatnosci"          => "2011-11-20",
      "SposobZaplaty"            => "PRZ",
      "RodzajPodpisuOdbiorcy"    => "BPO",
      "WidocznyNumerGios"        => false,
      "Numer"                    => nil,
      "IdentyfikatorKontrahenta" => 'Joe Black',
      "Kontrahent"               => {
        "Identyfikator" => 'Joe Black',
        "Nazwa"         => "joe",
        "NIP"           => "333-333-33-33",
        "Ulica"         => "Marszalkowska",
        "KodPocztowy"   => "12-345",
        "Miejscowosc"   => "Warszawa",
        "Email"         => "joe@example.org",
        "Telefon"       => "123456789"
      },
      "Pozycje" => [{
        "StawkaVat"       => "0.07",
        "Ilosc"           => 10,
        "CenaJednostkowa" => 100,
        "NazwaPelna"      => "Development",
        "Jednostka"       => "hour",
        "TypStawkiVat"    => "PRC"
      }]
    }
    @encoded_body = JSON.dump(@body)
  end

  let(:ifirma) { ifirma = Ifirma.new(:config => { :username => "drogus", :invoices_key => "AABB" }) }

  it "sends an invoice" do
    headers = {
      'Accept' => 'application/json',
      'Authentication' => 'IAPIS user=drogus, hmac-sha1=32fd2bb0d4746c286a0a2cf68f0d224bdc29b9f8',
      'Content-Type' => 'application/json; charset=utf-8',
    }

    stub_request(:post, "https://www.ifirma.pl/iapi/fakturakraj.json").
      with(:headers => headers, :body => @encoded_body).
      to_return(:body => {"response"=>{"Kod"=>0, "Informacja"=>"Faktura została pomyślnie dodana.", "Identyfikator"=>5721327}}.to_json, :headers => {"Content-Type" => "application/json"})

    response = ifirma.create_invoice(@payload)
    response.should be_success
    response.code.should == 0
    response.info.should == "Faktura została pomyślnie dodana."
    response.invoice_id.should == 5721327
  end

  it "sends an incorrect invoice" do
    payload_tmp = @payload
    payload_tmp.delete(:type)
    body_tmp = @body
    body_tmp.delete("LiczOd")
    encoded_body = JSON.dump(body_tmp)

    headers = {
      'Accept' => 'application/json',
      'Authentication' => 'IAPIS user=drogus, hmac-sha1=a7567c201a87bd5ef4a386408e3387fab1d4231c',
      'Content-Type' => 'application/json; charset=utf-8',
    }

    stub_request(:post, "https://www.ifirma.pl/iapi/fakturakraj.json").
      with(:headers => headers, :body => encoded_body).
      to_return(:body => {"response"=>{"Kod"=>401, "Informacja"=>"Niepoprawna nazwa użytkownika."}}.to_json, :headers => {"Content-Type" => "application/json"})

    response = ifirma.create_invoice(payload_tmp)
    response.should be_error
    response.code.should == 401
    response.info.should_not be_nil
  end

  it "getting an invoice, returns a successful response" do
    header = {
      'Accept' => 'application/json',
      'Authentication' => 'IAPIS user=drogus, hmac-sha1=a09fb9423c8145e873e603d5df392cd03ac20023',
      'Content-Type' => 'application/json; charset=utf-8',
    }
    stub_request(:get, "https://www.ifirma.pl/iapi/fakturakraj/5721327.json").
      with(:headers => header).
      to_return(:body => {"response" => {}}.to_json, :headers => {"Content-Type" => "application/json"})

    header = {
      'Accept' => 'application/json',
      'Authentication' => 'IAPIS user=drogus, hmac-sha1=854cc130ae59bd398aee15d9b86971e94526484a',
      'Content-Type' => 'application/json; charset=utf-8',
    }
    stub_request(:get, "https://www.ifirma.pl/iapi/fakturakraj/5721327.pdf").
      with(:headers => header).
      to_return(:body => "aaa")

    response = ifirma.get_invoice(5721327)
    response.should be_success
    response.body.should == 'aaa'
  end

  it "getting an invoice which doesn't exists, returns an error response" do
    header = {
      'Accept' => 'application/json',
      'Authentication' => 'IAPIS user=drogus, hmac-sha1=c782e1d21e81daba4a432ea89ead398b8fe246e3',
      'Content-Type' => 'application/json; charset=utf-8',
    }
    stub_request(:get, "https://www.ifirma.pl/iapi/fakturakraj/0.json").
      with(:headers => header).
      to_return(:body => {"response"=>{"Kod"=>500, "Informacja"=>"Faktura/rachunek nie istnieje."}}.to_json, :headers => {"Content-Type" => "application/json"})

    response = ifirma.get_invoice(0)
    response.should be_error
    response.code.should == 500
    response.info.should_not be_nil
  end

end
