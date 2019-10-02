//*****************************************************************************
//
// unit:   uPOSEnums
// Classe: TPOSEnums
//
// Data de cria��o  :  01/07/2019
// Autor            :
// Descri��o        :  Parametros da aplica��o
//
//*****************************************************************************/
unit uPOSEnums;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils, system.AnsiStrings,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Types, System.TypInfo;

type

  TCPOSEnums = class

private
{}
public



const

//==========================================================================================
// Defini��o da vers�o do aplicativo
//==========================================================================================

  PGWEBLIBTEST_VERSION = '2.1.1';
  PGWEBLIBTEST_AUTDEV  = 'AUTOMACAO DE SISTEMAS';
  PGWEBLIBTEST_AUTNAME = 'TestePOSPaygo';
  PGWEBLIBTEST_AUTCAP  = '15';
  PGWEBLIBTEST_AUTHTECHUSER  = 'PAYGOTESTE';

//==========================================================================================
//   Tipos de dados que podem ser informados pela Automa��o
//==========================================================================================
  PWINFO_OPERATION = 2;         //Transa��o que foi realizada: �00� � Sem Defini��o �01� � Venda (pagamento) �02� � Administrativa (geral) �04� � Estorno de Venda
  PWINFO_MERCHANTCNPJCPF = 28;  //CNPJ (ou CPF) do Estabelecimento / Ponto de captura
  PWINFO_TOTAMNT = 37;          //Valor da transa��o, em centavos. Este par�metro � mandat�rio para transa��es de venda (PTITRN_SALE) e de estorno (PTITRN_SALEVOID)
  PWINFO_CURRENCY = 38;         //C�digo da moeda, conforme o padr�o internacional ISO4217 (986 para Real, 840 para D�lar americano). Este par�metro � requerido sempre que PWINFO_TOTAMNT for informado
  PWINFO_FISCALREF = 40;        //N�mero da fatura (final nulo). Este par�metro � opcional.
  PWINFO_CARDTYPE = 41;         //Modalidade da transa��o do cart�o: 1: cr�dito; 2: d�bito; 4: voucher; 8: private label; 16: frota; 128: outros.
  PWINFO_PRODUCTNAME = 42;      //Nome/tipo do produto utilizado, na nomenclatura do Provedor.
  PWINFO_DATETIME = 49;         //Hor�rio do servidor PGWEB, format �YYMMDDhhmmss�.
  PWINFO_REQNUM = 50;           //Identificador �nico da transa��o (gerado pelo terminal).
  PWINFO_AUTHSYST = 53;         //C�digo da Rede Adquirente, conforme descrito no item 5.5. Caso este campo seja preenchido, a transa��o ser� realizada diretamente na rede adquirente especificada
  PWINFO_VIRTMERCH = 54;        //Identificador da afilia��o utilizada para o sistema de gerenciamento do terminal.
  PWINFO_AUTMERCHID = 56;       //Identificador do estabelecimento para a adquirente.
  PWINFO_FINTYPE = 59;          //Modalidade de financiamento da transa��o: 1: � vista; 2: parcelado pelo Emissor; 4: parcelado pelo Estabelecimento; 8: pr�-datado; 16: cr�dito emissor; 32: Pr�datado parcelado.
  PWINFO_INSTALLMENTS = 60;     //Quantidade de parcelas, para transa��es parceladas.
  PWINFO_INSTALLMDATE = 61;     //Data de vencimento do pr�datado, ou da primeira parcela. Formato �DDMMAA�.
  PWINFO_RESULTMSG = 66;        //Mensagem de texto que descreve o resultado da transa��o (sucesso ou falha).
  PWINFO_AUTLOCREF = 68;        //Identificador �nico da transa��o (gerado pelo sistema de gerenciamento do terminal).
  PWINFO_AUTEXTREF = 69;        //Identificador �nico da transa��o (gerado pela adquirente/processadora)
  PWINFO_AUTHCODE = 70;         //C�digo de autoriza��o (gerado pelo emissor).
  PWINFO_AUTRESPCODE = 71;      //Caso a transa��o chegue ao sistema autorizador, esse � o c�digo de resposta do mesmo  (bit39 da mensagem ISO8583).
  PWINFO_DISCOUNTAMT = 73;      //Valor do desconto concedido pelo Provedor, considerando PWINFO_CURREXP, j� deduzido em PWINFO_TOTAMNT.
  PWINFO_CASHBACKAMT = 74;      //Valor do saque/troco, considerando PWINFO_CURREXP, j� inclu�do em PWINFO_TOTAMNT.
  PWINFO_CARDNAME = 75;         //Nome do cart�o ou emissor
  PWINFO_BOARDINGTAX = 77;      //Valor da taxa de embarque, considerando PWINFO_CURREXP, j� inclu�do em PWINFO_TOTAMNT.
  PWINFO_TIPAMOUNT = 78;        //Valor da taxa de servi�o (gorjeta), considerando PWINFO_CURREXP, j� inclu�do em PWINFO_TOTAMNT.
  PWINFO_RCPTMERCH = 83;        //Comprovante � via do estabelecimento.
  PWINFO_RCPTCHOLDER = 84;      //Comprovante � via do portador.
  PWINFO_RCPTCHSHORT = 85;      //Comprovante � via reduzida
  PWINFO_TRNORIGDATE = 87;      //Data da transa��o original. Este campo � utilizado para transa��es de cancelamento. Formato DDMMAA.
  PWINFO_TRNORIGNSU = 88;       //N�mero de refer�ncia da transa��o original (atribu�do pela adquirente/processadora). Este par�metro � mandat�rio para transa��es de estorno (PTITRN_SALEVOID).
  PWINFO_TRNORIGAUTH = 98;      //C�digo de autoriza��o da transa��o original. Este campo � utilizado para transa��es de cancelamento.
  PWINFO_LANGUAGE = 108;        //Idioma a ser utilizado para a interface com o cliente: 0: Portugu�s 1: Ingl�s 2: Espanhol
  PWINFO_TRNORIGTIME = 115;     //Hor�rio da transa��o original. Este campo � utilizado para transa��es de cancelamento. Formato HHMMSS.
  PWPTI_RESULT = 129;           //Caso a execu��o da fun��o retorne PTIRET_EFTERR, este campo informa o detalhamento do erro.
  PWINFO_CARDENTMODE = 192;     //Modo de entrada do cart�o:  1: n�mero do cart�o digitado 2: tarja magn�tica 4: chip com contato EMV  16: fallback para tarja magn�tica  32: chip sem contato simulando tarja magn�tica 64: chip sem contato EMV 128: indica que a transa��o atual � oriunda de um fallback (flag enviado do servidor para o ponto de captura). 256: fallback de tarja para digitado
  PWINFO_CARDPARCPAN = 200;     //N�mero do cart�o mascarado
  PWINFO_CHOLDVERIF = 207;      //Verifica��o do portador do cart�o, soma de:  1: assinatura 2: verifica��o offline da senha 4: senha offline bloqueada durante a transa��o  8: verifica��o on-line da senha.
  PWINFO_MERCHADDDATA1 = 240;   //N�mero de refer�ncia da transa��o atribu�do pela Automa��o Comercial. Caso fornecido, este n�mero ser� inclu�do no hist�rico de dados da transa��o e encaminhado � adquirente/processadora, se suportado. Este par�metro � opcional.
  PWINFO_MERCHADDDATA2 = 241;   //Dados adicionais espec�ficos do neg�cio. Caso fornecido, ser� incluso no hist�rico de dados da transa��o, por exemplo para refer�ncias cruzadas. Este par�metro � opcional.
  PWINFO_MERCHADDDATA3 = 242;   //Dados adicionais espec�ficos do neg�cio. Caso fornecido, ser� incluso no hist�rico de dados da transa��o, por exemplo para refer�ncias cruzadas. Este par�metro � opcional.
  PWINFO_MERCHADDDATA4 = 243;   //Dados adicionais espec�ficos do neg�cio. Caso fornecido, ser� incluso no hist�rico de dados da transa��o, por exemplo para refer�ncias cruzadas. Este par�metro � opcional.
  PWINFO_PNDAUTHSYST = 32517;   //Nome do provedor para o qual existe uma transa��o pendente.
  PWINFO_PNDVIRTMERCH = 32518;  //Identificador do Estabelecimento para o qual existe uma transa��o pendente.
  PWINFO_PNDAUTLOCREF = 32520;  //Refer�ncia para a infraestrutura Erro! Nome de propriedade do documento desconhecido. da transa��o que est� pendente.
  PWINFO_PNDAUTEXTREF = 32521;  //Refer�ncia para o Provedor da transa��o que est� pendente.
  PWINFO_DUEAMNT = 48902;       //Valor devido pelo usu�rio, considerando PWINFO_CURREXP, j� deduzido em PWINFO_TOTAMNT.
  PWINFO_READJUSTEDAMNT = 48905;//Valor total da transa��o reajustado, este campo ser� utilizado caso o autorizador, por alguma regra de neg�cio espec�fica dele, resolva alterar o valor total que foi solicitado para a transa��o.


//==========================================================================================
//   Status final para a transa��o
//==========================================================================================
  PTICNF_SUCCESS  = 1; // Transa��o confirmada.
  PTICNF_PRINTERR = 2; // Erro na impressora, desfazer a transa��o
  PTICNF_DISPFAIL = 3; // Erro com o mecanismo dispensador, desfazer a transa��o
  PTICNF_OTHERERR = 4; // Outro erro, desfazer a transa��o.



//==========================================================================================
//   Identificadores da c�pia do recibo:
//==========================================================================================
  PTIPRN_MERCHANT = 1;  // Via do estabelecimento
  PTIPRN_CHOLDER  = 2;  // Via do portador do cart�o


//==========================================================================================
//  Tabela de C�digos de Erro de Retorno da Biblioteca
//==========================================================================================
  ERRO_INTERNO = 99;            //Erro desta aplica��o
  PTIRET_OK = 0;                //Opera��o bem-sucedida
  PTIRET_INVPARAM = -2001;      //Par�metro inv�lido informado � fun��o.
  PTIRET_NOCONN = -2002;        //O terminal est� offline
  PTIRET_BUSY = -2003;          //O terminal est� ocupado processando outro comando.
  PTIRET_TIMEOUT = -2004;       //Usu�rio falhou ao pressionar uma tecla durante o tempo especificado
  PTIRET_CANCEL = -2005;        //Usu�rio pressionou a tecla [CANCELA].
  PTIRET_NODATA = 2006;         //Informa��o requerida n�o dispon�vel
  PTIRET_BUFOVRFLW = -2007;     //Dados maiores que o tamanho do buffer fornecido
  PTIRET_SOCKETERR = -2008;     //Impossibilitado de iniciar escuta das portas TCP especificadas
  PTIRET_WRITEERR = -2009;      //Impossibilitado de utilizar o diret�rio especificado
  PTIRET_EFTERR = -2010;        //A opera��o financeira foi completada, por�m falhou
  PTIRET_INTERNALERR = -2011;   //Erro interno da biblioteca de integra��o
  PTIRET_PROTOCOLERR = -2012;   //Erro de comunica��o entre a biblioteca de integra��o e o terminal
  PTIRET_SECURITYERR = -2013;   //A fun��o falhou por quest�es de seguran�a
  PTIRET_PRINTERR = -2014;      //Erro na impressora
  PTIRET_NOPAPER = -2015;       //Impressora sem papel
  PTIRET_NEWCONN = -2016;       //Novo terminal conectado
  PTIRET_NONEWCONN = -2017;     //Sem recebimento de novas conex�es.
  PTIRET_NOTSUPPORTED = -2057;  //Fun��o n�o suportada pelo terminal.
  PTIRET_CRYPTERR = -2058;      //Erro na criptografia de dados (comunica��o entre a biblioteca de integra��o e o terminal).



//==========================================================================================
// Definicoes das teclas do POS
//==========================================================================================
  PTIKEY_0       = 48;
  PTIKEY_1       = 49;
  PTIKEY_2       = 50;
  PTIKEY_3       = 51;
  PTIKEY_4       = 52;
  PTIKEY_5       = 53;
  PTIKEY_6       = 54;
  PTIKEY_7       = 55;
  PTIKEY_8       = 56;
  PTIKEY_9       = 57;
  PTIKEY_STAR    = '*';
  PTIKEY_HASH    = '#';
  PTIKEY_DOT     = '.';
  PTIKEY_00      = 37;
  PTIKEY_BACKSP  = 8;
  PTIKEY_OK      = 13;
  PTIKEY_CANCEL  = 27;
  PTIKEY_FUNC0   = 97;
  PTIKEY_FUNC1   = 98;
  PTIKEY_FUNC2   = 99;
  PTIKEY_FUNC3   = 100;
  PTIKEY_FUNC4   = 101;
  PTIKEY_FUNC5	 = 102;
  PTIKEY_FUNC6	 = 103;
  PTIKEY_FUNC7	 = 104;
  PTIKEY_FUNC8	 = 105;
  PTIKEY_FUNC9	 = 106;
  PTIKEY_FUNC10	 = 107;
  PTIKEY_TOUCH   = 126;
  PTIKEY_ALPHA   = 38;


//==========================================================================================
//   Tipos de transa��es
//==========================================================================================
  PWOPER_ADMIN    = 32;  // Qualquer transa��o que n�o seja um pagamento(estorno, pr�-autoriza��o, consulta, relat�rio, reimpress�o de recibo, etc.).
  PWOPER_SALE     = 33;  // Pagamento de mercadorias ou servi�os.
  PWOPER_SALEVOID = 34;  // Estorna uma transa��o de venda que foi previamente realizada e confirmada


//==========================================================================================
// Tipos de aviso sonoro:
//==========================================================================================
  PTIBEEP_OK       = 0;  // Sucesso
  PTIBEEP_WARNING  = 1;  // Alerta
  PTIBEEP_ERROR    = 2;  // Erro


//==========================================================================================
// Modalidade de Financiamneto da Transa��o
//==========================================================================================
  a_vista = 1;
  parcelado_pelo_Emissor = 2;
  parcelado_pelo_Estabelecimento = 4;
  pr�_datado = 8;
  cr�dito_emissor = 16;
  Pr�datado_parcelado = 32;


//==========================================================================================
// Modalidade da transa��o do cart�o:
//==========================================================================================
  Credito = 1;
  Debito = 2;
  Voucher = 4;
  Private_Label = 8;
  Frota = 16;
  Outros = 128;


//==========================================================================================
// Status do Terminal
//==========================================================================================

  PTISTAT_IDLE = 0;        // Terminal est� on-line e aguardando por comandos.
  PTISTAT_BUSY = 1;        // Terminal est� on-line, por�m ocupado processando um comando
  PTISTAT_NOCONN = 2;      // Terminal est� offline.
  PTISTAT_WAITRECON = 3;   // Terminal est� off-line. A transa��o continua sendo executada e
                           // ap�s sua finaliza��o, o terminal tentar� efetuar a reconex�o
                           // automaticamente.



//==========================================================================================
//
//==========================================================================================
   WInputH:Integer = 550;
   WInputV:Integer = 140;



  Constructor Create;    // declara��o do metodo construtor

  Destructor  Destroy; Override; // declara��o do metodo destrutor



  end;


var
eCclasse:TCPOSEnums;


implementation

{ TCEnums }

{ TCPOSEnums }

constructor TCPOSEnums.Create;
begin

end;

destructor TCPOSEnums.Destroy;
begin

  inherited;
end;

end.
