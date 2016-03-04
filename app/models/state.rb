class State
  include ActiveModel

  UFS = {
    'Florianópolis' => 'SC',
    'João Pessoa' => 'PB',
    'Novo Hamburgo' => 'RS',
    'Porto Alegre' => 'RS',
    'Rio de Janeiro' => 'RJ',
    'Santos' => 'SP',
    'São Gonçalo' => 'RJ',
    'Tubarão' => 'SC'
  }

  NAMES = {
   'Florianópolis' => 'Santa Catarina',
    'João Pessoa' => 'Paraíba',
    'Novo Hamburgo' => 'Rio Grande do Sul',
    'Porto Alegre' => 'Rio Grande do Sul',
    'Rio de Janeiro' => 'Rio de Janeiro',
    'Santos' => 'São Paulo',
    'São Gonçalo' => 'Rio de Janeiro',
    'Tubarão' => 'Santa Catarina'
  }

end