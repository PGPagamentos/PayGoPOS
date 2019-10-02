//************************************************************************************
  {
     unit:   POSPGWLib
     Classe: TPOSPGWLib

     Data de cria��o  :  02/07/2019
     Autor            :
     Descri��o        :  Metodos de Interoperabilidade com DLL
   }
//************************************************************************************
unit uPOSPGWLib;

interface


uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils, system.AnsiStrings,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Types, System.TypInfo, uPOSEnums, uLib;



Type

       CPT_GetpszData = record
            pszData: Array[0..21] of AnsiChar;
       end;
       PSZ_GetpszData = Array[0..0] of CPT_GetpszData;



       CPT_GetpszTerminalId = record
            pszTerminalId: Array[0..21] of AnsiChar;
       end;
       PSZ_GetpszTerminalId = Array[0..0] of CPT_GetpszTerminalId;


       CPT_GetpszModel = record
            pszModel: Array[0..21] of AnsiChar;
       end;
       PSZ_GetpszModel = Array[0..0] of CPT_GetpszModel;


       CPT_GetpszMAC = record
            pszMAC: Array[0..18] of AnsiChar;
       end;
       PSZ_GetpszMAC = Array[0..0] of CPT_GetpszMAC;


       CPT_GetpszSerNum = record
            pszSerNum: Array[0..26] of AnsiChar;
       end;
       PSZ_GetpszSerNum = Array[0..0] of CPT_GetpszSerNum;


       CPT_GetiStatus = record
            piStatus: Byte;
       end;
       PSZ_GetiStatus = Array[0..0] of CPT_GetiStatus;

       CPT_GetiRet = record
            piRet: Integer;
       end;
       PSZ_GetiRet = Array[0..0] of CPT_GetiRet;


       CPT_GetpszValue = record
            pszValue: Array[0..2048] of AnsiChar;
       end;
       PSZ_GetpszValue = Array[0..0] of CPT_GetpszValue;




  TPOSPGWLib = class
  private
    { private declarations }
  protected
    { protected declarations }
  public

    POSenums   : TCPOSEnums;


    isRunning: Boolean;

    appListeningPort: Integer;
    currentNumberOfTerminals: Integer;
    maxNumberOfTerminals: Integer;
    pasta:string;

    msgIdle:String;
    appCompany:string;
    appVersion:string;
    appWorkingPath:string;
    appCapabilities:string;
    appuiAutoDiscSec:UInt16;

    WszTerminalId :AnsiString;
    WszModel : AnsiString;
    WszMAC: AnsiString;
    WszSerNum: AnsiString;
    WszStatus: SHORT;


    constructor Create;
    Destructor  Destroy; Override; // declara��o do metodo destrutor

    function Init:Integer;
    function Conexao:Integer;
    function NovaConexao:Integer;
    function menuoperacoes(WTerminal:AnsiString):Integer;
    function menuprincipal(WTerminal:AnsiString):Integer;
    function menuimpressao(WTerminal:AnsiString):Integer;
    function menucaptura(WTerminal:AnsiString):Integer;
    function menucodigos(WTerminal:AnsiString):Integer;
    function operacaovenda(WTerminal:AnsiString):Integer;
    function operacaocancela(WTerminal:AnsiString):Integer;
    function operacaoadmin(WTerminal:AnsiString):Integer;
    function confirmacao(Wterminal:AnsiString):Integer;
   // function ConexaoCancela:Integer;
   // function NovaConexaoCancela:Integer;
    function PrintResultParams(WterminalID:AnsiString):Integer;
    function pszGetInfoDescription(wIdentificador:Integer):string;
    function PrintReturnDescription(iReturnCode:Integer; pszDspMsg:string):Integer;
    function Finalizar:Integer;
    //
    //function ConexaoExemplo:Integer;
    //function Cancelamento:Integer;
    function MandaMemo(Descr:string):integer;
    function Desconectar:Integer;

end;


//===============================================================================================*\
 {

 Function     :  TPOSPGWLib.PTI_Init

 Descricao    : Esta fun��o configura a biblioteca de integra��o e deve ser a primeira a ser chamada
                pela Automa��o Comercial. A biblioteca de integra��o somente aceitar� conex�es do terminal
                de pagamento ap�s sua chamada.


 Entrada:       pszPOS_Company  .........= Nome da empresa de Automa��o Comercial (final-nulo, at� 40 caracteres e sem acentua��o). Por exemplo, "KND SISTEMAS LTDA.".


                pszPOS_Version  .........= Nome e vers�o da aplica��o de Automa��o Comercial (final-nulo, at� 40 caracteres e sem acentua��o).
                                           Por exemplo, �SUPERVENDAS v1.01�.


                pszPOS_Capabilities .....= Capacidades da Automa��o (soma dos valores abaixo):
                                           1:  funcionalidade de troco/saque;
                                           2:  funcionalidade de desconto;
                                           4:  valor fixo, sempre incluir;
                                           8:  impress�o das vias diferenciadas do comprovante para Cliente/Estabelecimento;
                                           16: impress�o do cupom reduzido.
                                           32: utiliza��o de saldo total do voucher para abatimento do valor da compra.

                pszDataFolder ...........= Caminho completo do diret�rio para armazenar dados e logs da biblioteca de integra��o.
                                           Observa��o: O usu�rio do sistema operacional onde � executada a aplica��o de Automa��o Comercial
                                           deve ter permiss�o de grava��o nesse diret�rio

                uiTCP_Port  .............= Porta TCP � qual todos os terminais ir�o conectar.
                                           Observa��o: esta porta deve estar habilitada para o recebimento de conex�es
                                           atrav�s de qualquer firewall que estiver no caminho entre a aplica��o de Automa��o Comercial e o terminal de POS.

                uiMaxTerminals ......... = N�mero m�ximo de conex�es simult�neas de terminais.

                pszWaitMsg ............. = Mensagem a ser apresentada na tela de qualquer terminal imediatamente ap�s se conectar. Veja PTI_Display para informa��es de formata��o.


               uiAutoDiscSec ........... = Tempo de ociosidade em segundos ap�s o qual o terminal deve se desconectar da Automa��o Comercial
                                           quando opera sem alimenta��o externa, ou zero para nunca desconectar. Veja PTI_Disconnect para informa��es adicionais.



 Saidas        :  none.

 Retorno       :  PTIRET_OK          Opera��o bem-sucedida
                  PTIRET_INVPARAM    Par�metro inv�lido informado � fun��o
                  PTIRET_SOCKETERR   Erro ao iniciar a escuta da porta TCP informada
                  PTIRET_WRITEERR    Erro no uso do diret�rio informado
 }
//===============================================================================================*/
  function PTI_Init(pszPOS_Company:AnsiString; pszPOS_Version:AnsiString; pszPOS_Capabilities:AnsiString;
                        pszDataFolder:AnsiString; uiTCP_Port:UInt16; uiMaxTerminals:UInt16;
                        pszWaitMsg:AnsiString; uiAutoDiscSec:UInt16;  var iRet:SHORT):Int16;  stdCall; External 'PTI_DLL.dll';


 //===============================================================================================
   {
     Function      :  PTI_End

     Descricao     :  Esta fun��o deve ser a �ltima fun��o chamada pela Automa��o Comercial, quando finalizada
                      ou antes de descarregar a biblioteca de integra��o.
                      Neste momento, a biblioteca de integra��o libera todos recursos alocados (portas TCP, processos, mem�ria, etc.).

     Input         :  none.

     Output        :  none.

     Return        :  none.
  }
//===============================================================================================*/
  function PTI_End():Int16; stdCall; External 'PTI_DLL.dll';



//===============================================================================================
  {
     Function      :  PTI_CheckStatus

     Descricao     :  Esta fun��o permite que a Automa��o Comercial verifique o status (on-line ou offline)
                      de determinado terminal de pagamento e recupere informa��es adicionais do equipamento.

                      Cada terminal de pagamento recebe um �nico identificador l�gico, que � configurado quando o
                      terminal � instalado. Se a Automa��o Comercial controla mais de um terminal, ela deve ter registro
                      de todos os identificadores e suas localiza��es, com a finalidade de poder enviar comandos para o terminal desejado.


     Entrada       :  pszTerminalId  Identificador �nico do terminal (final nulo). Pode ser vazio se o n�mero m�ximo de terminais
                      suportado (informado em PTI_Init) for 1.


     Saida         :  pszTerminalId  Identificador �nico do terminal (final nulo, at� 20 caracteres).

                      piStatus       Status do terminal (PTISTAT_xxx).

                      pszModel       Modelo do terminal (final nulo at� 20 caracteres).

                      pszMAC         Endere�o MAC do terminal (final nulo, formato �XX:XX:XX:XX:XX:XX�)

                      pszSerNo       N�mero de s�rie do terminal (final nulo, at� 25 caracteres).

     Retorno      :  PTIRET_OK      Opera��o bem sucedida.


     Lista de Possiveis Status(piStatus):
     ==================================
     Nome              Valor     Descri��o
     PTISTAT_IDLE        0       Terminal est� on-line
     PTISTAT_BUSY        1       Terminal est� on-line, por�m ocupado processando um comando.
     PTISTAT_NOCONN      2       Terminal est� offline.
     PTISTAT_WAITRECON   3       Terminal est� off-line. A transa��o continua sendo executada e
                                 ap�s sua finaliza��o, o terminal tentar� efetuar a reconex�o
                                 automaticamente.
  }
//===============================================================================================
  function PTI_CheckStatus(pszTerminalId:  AnsiString; var piStatus:SHORT; pszModel:AnsiString;
                           pszMAC:AnsiString; pszSerNo:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';


//==============================================================================================
  {
     Function      :  PTI_Disconnect

     Descricao     :  Esta fun��o permite que a Automa��o Comercial desconecte um terminal de pagamento e o coloque
                      em modo offline, seja imediatamente ou ap�s algum tempo funcionando sem alimenta��o externa.

                      Para terminais m�veis, permanecer on-line aumenta consideravelmente o consumo da bateria. Por
                      este motivo � recomendado que a Automa��o Comercial defina um valor diferente de zero para o
                      par�metro uiAutoDiscSec de PTI_Init, ou chame essa fun��o assim que o terminal conectar.

                      Ap�s o terminal ficar offline, t�o logo uma tecla � pressionada, este se conecta automaticamente
                      novamente � Automa��o Comercial.


     Entrada       :  pszTerminalId  Identificador �nico do terminal (final nulo).

                      uiPwrDelay     Se igual a zero, desconecta imediatamente o terminal, independentemente
                                     de sua fonte de energia.
                                     Se diferente de zero, representa o n�mero m�ximo de segundos durante os
                                     quais o terminal permanecer� on-line enquanto estiver operando sem
                                     alimenta��o externa. O terminal n�o ficar� offline enquanto estiver
                                     conectado a uma fonte de alimenta��o externa. Este valor sobrescreve o
                                     par�metro uiAutoDiscSec de PTI_Init para este terminal espec�fico.

     Saida         :  none.

     Retorno       :  PTIRET_OK      Opera��o bem-sucedida.
                      PTIRET_NOCONN  O terminal est� offline.
                      PTIRET_BUSY     O terminal est� ocupado processando outro comando
   }
//===============================================================================================
  function PTI_Disconnect(pszTerminalId:AnsiString; uiPwrDelay:UInt16):Int16; stdCall; External 'PTI_DLL.dll';




//===============================================================================================
  {
    Function       :  PTI_Display

    Descricao      :  Esta fun��o apresenta uma mensagem na tela do terminal e retorna imediatamente.
                      A mensagem � apresentada a partir do canto superior esquerdo da tela, sendo 20 caracteres por
                      linha, com quebra de linha identificada pelo caractere �\r� (retorno ao in�cio da linha, c�digo
                      ASCII 13). Caracteres que ultrapassem as 20 colunas ou o n�mero m�ximo de linhas s�o descartados.
                      O n�mero m�ximo de linhas suportado pode variar dependendo do modelo do terminal, entretanto
                      o m�nimo de quatro linhas � sempre suportado.

    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).
                      pszMsg         Mensagem a ser apresentada na tela do terminal (final nulo).

    Saida          :  none.

    Retorno        :  PTIRET_OK            Opera��o bem-sucedida.
                      PTIRET_INVPARAM      Par�metro inv�lido passado � fun��o. PTIRET
                      PTIRET_NOCONN        O terminal est� offline
                      PTIRET_BUSY          O terminal est� ocupado processando outro comando

   }
//===============================================================================================
  function PTI_Display(pszTerminalId:AnsiString; pszMsg:AnsiString; var iRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//============================================================================================================================================
  {
    Function       :  PTI_WaitKey

    Descricao      :  Esta fun��o aguarda o pressionar de uma tecla no terminal e apenas retorna ap�s uma tecla ser
                      pressionada ou quando o tempo de espera se esgotar
                      Importante: Esta fun��o somente deve ser utilizada para captura isolada de teclas, n�o devendo ser
                      sucessivamente chamada para captura de dados de entrada. Para este prop�sito, PTI_GetData deve
                      ser utilizado.


    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).
                      uiTimeOutSec   Tempo de espera do usu�rio, em segundos. Se igual a zero, a fun��o retorna
                                     imediatamente, somente informando que uma tecla foi pressiona caso tenha
                                     sido feito antes da chamada � fun��o. (Captura de tecla buferizada.)

    Saida          :  piKey          Identificador da tecla que foi pressionada, de acordo com a tabela abaixo
                                     (somente se o retorno da fun��o for PTIRET_OK).

    Retorno        :  PTIRET_OK            Opera��o bem-sucedida, uma tecla foi pressionada.
                      PTIRET_NOCONN        O terminal est� offline
                      PTIRET_BUSY          O terminal est� ocupado processando outro comando.
                      PTIRET_TIMEOUT       Nenhuma tecla foi pressionada durante o per�odo de tempo
                                           especificado.

   }
//============================================================================================================================================
  function PTI_WaitKey(pszTerminalId:AnsiString; uiTimeOutSec:UInt16; var piKey:SHORT; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';



//===========================================================================
  {
    Funcao     :  PTI_ConnectionLoop

    Descricao  :  Esta fun��o permite que a Automa��o Comercial verifique quando um novo
                  terminal se conectou e, se PTIRET_NEWCONN � retornado,
                  recupere informa��es adicionais do equipamento.

    Entradas   :  nenhuma.

    Saidas     :  pszTerminalId  : Identificador �nico do terminal (final nulo, at� 20 caracteres).
                  pszModel       : Modelo do terminal (final nulo, at� 20 caracteres).
                  pszMAC         : Endere�o MAC do terminal (final nulo, formato �XX:XX:XX:XX:XX:XX�).
                  pszSerNo       : N�mero serial do terminal (final nulo, at� 25 caracteres).


    Retorno    :  PTIRET_NEWCONN    :  Novo terminal conectado.
                  PTIRET_NONEWCONN  :  Sem novas conex�es recebidas.
  }
//===========================================================================

  function PTI_ConnectionLoop(var pszTerminalId:PSZ_GetpszTerminalId; var pszModel:PSZ_GetpszModel; var pszMAC:PSZ_GetpszMAC;
                              var pszSerNo:PSZ_GetpszSerNum; var piRet:Int16):Int16; stdCall; External 'PTI_DLL.dll';




//========================================================================================================
  {
    Function       :  PTI_ClearKey

    Descri��o      :  Esta fun��o limpa o buffer de teclas pressionadas,
                      para que a pr�xima chamada da fun��o n�o considere qualquer tecla previamente pressionada.
                      Esta fun��o retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).

    Saida          :  Nenhuma.

    Retorno(piRet) :  PTIRET_OK             Opera��o bem-sucedida
                      PTIRET_NOCONN         O terminal est� offline
                      PTIRET_BUSY           O terminal est� ocupado processando outro comando.
   }
//========================================================================================================
  function PTI_ClearKey (pszTerminalId:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//===============================================================================================
  {
  Function       :  PTI_GetData

  Descri��o      :  Esta fun��o realiza a captura de um �nico dado em um terminal previamente conectado.
                    Esta fun��o � blocante e somente retorna ap�s a captura de dado ser bem-sucedida ou falhar.

  Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).
                    pszPrompt      Mensagem de texto com final nulo a ser apresentada ao usu�rio,
                                   descrevendo a informa��o a ser solicitada.
                                   Utilize �\r� (c�digo ASCII 13) para quebra de linha. Por exemplo: �VALOR DO SERVICO:�.
                    pszFormat      M�scara de formata��o com final nulo. Utilize �@� (arroba) para as posi��es de caracteres edit�veis.
                                   Por exemplo: �@@.@@@.@@@,@@� para um valor em centavos.
                                   Deve ser nulo (NULL) ou vazio para captura direta sem formata��o
                    uiLenMin       N�mero m�nimo de caracteres
                    uiLenMax       N�mero m�ximo de caracteres
                    fFromLeft      TRUE (1) para iniciar a digita��o da esquerda;
                                   FALSE (0) para iniciar a digita��o da direita.
                    fAlpha         TRUE (1) para habilitar a entrada de caracteres n�o num�ricos;
                                   FALSE (0) para permitir apenas caracteres num�ricos.
                                   Nota: como a digita��o de caracteres n�o num�ricos em muitos terminais n�o � amig�vel,
                                   recomenda-se evitar o uso desse recurso sempre que poss�vel
                    fMask          TRUE (1) para mascarar os caracteres digitados com asterisco
                                   (tipicamente, para digita��o de senha);  FALSE (0) para mostrar os caracteres digitados
                    uiTimeOutSec   Tempo m�ximo entre cada tecla pressionada, em segundos.
                    pszData        Valor inicial para um dado a ser editado com final nulo.
                    uiCaptureLine  �ndice da linha da tela (iniciando em 1) onde a informa��o digitada deve ser apresentada.
                                   Caso a legenda da mensagem tamb�m for apresentada nessa linha,
                                   a informa��o digitada ser� exibida logo ap�s a legenda;
                                   sen�o, ser� exibida iniciando na primeira coluna.

  Saida          :  pszData  Informa��o digitada com final nulo (somente caso a fun��o retorne PTIRET_OK)

  Retorno        :  PTIRET_OK            Captura de dado bem-sucedida
                    PTIRET_INVPARAM      Par�metro inv�lido passado � fun��o
                    PTIRET_NOCONN        O terminal est� offline.
                    PTIRET_BUSY          O terminal est� ocupado processando outro comando
                    PTIRET_TIMEOUT       Nenhuma tecla foi pressionada no tempo especificado.
                    PTIRET_CANCEL        Usu�rio pressionou a tecla [CANCELA].
                    PTIRET_SECURITYERR   A fun��o foi rejeitada por quest�es de seguran�a.
   }
//===============================================================================================
  function PTI_GetData (pszTerminalId:AnsiString; pszPrompt:AnsiString; pszFormat:AnsiString; uiLenMin:UInt16;
                        uiLenMax:UInt16; fFromLef:BOOL; fAlpha:BOOL; fMask:BOOL;
                        uiTimeOutSec:UInt16; var pszData:PSZ_GetpszData; uiCaptureLine:UInt16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';



//=========================================================================================================
  {
    Function       :  PTI_StartMenu

    Descri��o      :  Esta fun��o inicia a constru��o de um menu de op��o para sele��o pelo usu�rio.
                      Esta fun��o retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).

    Saida          :  Nenhum.

    Retorno        :  PTIRET_OK       Cria��o do menu iniciada
                      PTIRET_NOCONN   O terminal est� offline
                      PTIRET_BUSY     O terminal est� ocupado processando outro comando.
   }
//=========================================================================================================
  function PTI_StartMenu (pszTerminalId:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//===================================================================================================================================
  {
    Function       :  PTI_AddMenuOption

    Descri��o      :  Esta fun��o adiciona uma op��o ao menu que foi criado atrav�s de PTI_StartMenu.
                      Esta fun��o retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).
                      pszOption      Mensagem de texto com final nulo que descreve a op��o a ser exibida no
                                     terminal (m�ximo: 18 caracteres).

    Saida          :  none.

    Retorno        :  PTIRET_OK        A op��o foi adicionada ao menu
                      PTIRET_INVPARAM  Par�metro inv�lido passado � fun��o
                      PTIRET_NOCONN    O terminal est� offline.
                      PTIRET_BUSY      O terminal est� ocupado processando outro comando
   }
//===================================================================================================================================
  function PTI_AddMenuOption (pszTerminalId:AnsiString; pszOption:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//=============================================================================================================================
  {
      Function       :  PTI_ExecMenu

      Descri��o      :  Esta fun��o exibe o menu de op��es que foi criado atrav�s de PTI_StartMenu
                        e PTI_AddMenuOption e identifica a sele��o feita pelo usu�rio.
                        Esta fun��o � blocante e somente retorna ap�s a sele��o de uma op��o ou a ocorr�ncia de um erro.

      Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).
                        pszPrompt      Mensagem de texto com final nulo a ser apresentada ao usu�rio
                                       no topo do menu (m�ximo: 20 caracteres).
                                       Por exemplo: �SELECIONE UMA OPCAO:�.
                                       Caso NULL ou vazio, o menu � exibido a partir da primeira linha da tela.
                        uiTimeOutSec   Tempo m�ximo entre duas teclas pressionadas, em segundos.
                        puiSelection   �ndice (iniciado em zero) da op��o que deve estar pr�-selecionada quando o
                                       menu for inicialmente exibido, fazendo com que esta op��o seja selecionada
                                       se o usu�rio simplesmente pressionar [OK]. Caso puiSelection n�o seja uma
                                       op��o v�lida, nenhuma � pr�-selecionada.


      Saida         :  puiSelection   �ndice (iniciado em zero) da op��o que foi selecionada pelo usu�rio (somente
                                      se a fun��o retornar PGWRET_OK)

      Retorno       :  PTIRET_OK          Sele��o do menu bem-sucedida.
                       PTIRET_INVPARAM    Par�metro inv�lido passado � fun��o
                       PTIRET_NOCONN      O terminal est� offline.
                       PTIRET_BUSY        O terminal est� ocupado processando outro comando
                       PTIRET_TIMEOUT     Nenhuma tecla foi pressionada durante o tempo especificado
                       PTIRET_CANCEL      Usu�rio pressionou a tecla [CANCELA].
   }
//=============================================================================================================================
  function PTI_ExecMenu (pszTerminalId:AnsiString; pszPrompt:AnsiString; uiTimeOutSec:UInt16;
                         var puiSelection:ShortInt; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';


//==================================================================================================================
  {
    Function       :  PTI_Beep

    Descri��o      :  Esta fun��o emite um aviso sonoro no terminal. Esta fun��o retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).
                      iType          Tipo de aviso sonoro, de acordo com a tabela abaixo

    Saida          :  Nenhuma.

    Retorno        :  PTIRET_OK          Opera��o bem-sucedida
                      PTIRET_INVPARAM    Par�metro inv�lido passado � fun��o
                      PTIRET_NOCONN      O terminal est� offline
                      PTIRET_BUSY        O terminal est� ocupado processando outro comando
  }
//==================================================================================================================
  function PTI_Beep (pszTerminalId:AnsiString; iType:Int16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//==========================================================================================================================
  {
    Function       :  PTI_Print

    Descri��o      :  Esta fun��o imprime uma ou mais linhas de texto na impressora do terminal e
                      retorna imediatamente. At� 40 caracteres por linha podem ser impressos,
                      com quebras de linha identificadas pelo caractere �\r� (c�digo ASCII 13).
                      Caracteres al�m das 40 colunas ser�o descartados.
                      Um caractere de controle na primeira posi��o de uma linha indica a mudan�a
                      da fonte do caractere utilizada para o texto da linha inteira.
                      Caso o primeiro caractere de uma linha n�o � um caractere de controle,
                      a fonte padr�o � utilizada. Os caracteres de controle suportados s�o:

                     Caractere de controle   C�digo ASCII do caractere         Efeito
                     =====================   =========================         ======
                          �\v�                          11                Dobra a largura da fonte, consequentemente
                                                                          o n�mero de colunas suportado � dividido por dois.


                     "PTI_PrnFeed deve ser chamada ap�s uma ou mais chamadas a PTI_Print."


    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).

                      pszText        Texto a ser impresso (final nulo).

    Saida          :  Nenhuma.

    Retorno(piRet) :  PTIRET_OK            Opera��o bem-sucedida
                      PTIRET_INVPARAM      Par�metro inv�lido passado � fun��o
                      PTIRET_NOCONN        O terminal est� offline
                      PTIRET_BUSY          O terminal est� ocupado processando outro comando
                      PTIRET_NOTSUPORTED   Fun��o n�o suportada pelo terminal
  }
//==========================================================================================================================
  function PTI_Print (pszTerminalId:AnsiString; pszText:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//========================================================================================================
  {
      Function       :  PTI_PrnFeed

      Descri��o      :  Esta fun��o avan�a algumas linhas do papel da impressora,
                        para permitir que o usu�rio destaque o recibo

      Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).

      Saida          :  Nenhuma.

      Retorno(piRet) :  PTIRET_OK            Opera��o bem-sucedida
                        PTIRET_INVPARAM      Par�metro inv�lido passado � fun��o
                        PTIRET_NOCONN        O terminal est� offline
                        PTIRET_BUSY          O terminal est� ocupado processando outro comando
                        PTIRET_PRINTERR      Erro na impressora
                        PTIRET_NOPAPER       Impressora sem papel
                        PTIRET_NOTSUPORTED   Fun��o n�o suportada pelo terminal
   }
//========================================================================================================
  function PTI_PrnFeed (pszTerminalId:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//=======================================================================================================================
  {
    Function       :  PTI_EFT_Start

    Descri��o      :  A Automa��o Comercial deve chamar esta fun��o para iniciar qualquer nova transa��o.
                      Esta fun��o retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).

                      iOper          Tipo de transa��o, de acordo a tabela abaixo

    Saida          :  Nenhuma.

    Retorno        :  PTIRET_OK         Opera��o bem-sucedida
                      PTIRET_INVPARAM   Par�metro inv�lido passado � fun��o.
                      PTIRET_NOCONN     O terminal est� offline
                      PTIRET_BUSY       O terminal est� ocupado processando outro comando

                      Lista dos tipos de transa��es:
                      ==============================
                      Nome                  Valor     Descri��o
                      ====================  =====     ====================================
                      PWOPER_SALE            33       Pagamento de mercadorias ou servi�os.
                      PWOPER_ADMIN           32       Qualquer transa��o que n�o seja um pagamento (estorno,
                                                      pr�-autoriza��o, consulta, relat�rio, reimpress�o de recibo,etc).
                      PWOPER_SALEVOID        34       Estorna uma transa��o de venda que foi previamente
                                                      realizada e confirmada.
  }
//=======================================================================================================================
  function PTI_EFT_Start (pszTerminalId:AnsiString; iOper:Int16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//===============================================================================================================================================
  {
    Function       :  PTI_EFT_AddParam

    Descri��o      :  A Automa��o Comercial deve chamar esta fun��o iterativamente ap�s PTI_EFT_Start para definir
                      todos os par�metros dispon�veis para a transa��o. Esta fun��o retorna imediatamente.

    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).

                      iParam         Identificador do par�metro, de acordo com o cap�tulo �TAG�s de entrada e sa�da�.

                      pszValue       Valor do par�metro (final nulo).

    Saida         :  none.

    Retorno       :  PTIRET_OK         Successful operation.
                     PTIRET_INVPARAM   Invalid parameter passed to the function.
                     PTIRET_NOCONN     The terminal is offline.
                     PTIRET_BUSY       The terminal is busy processing another command.
   }
//===============================================================================================================================================
  function PTI_EFT_AddParam (pszTerminalId:AnsiString; iParam:Int16; pszValue:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//=========================================================================================================
  {
    Function       :  PTI_EFT_Exec

    Descri��o      :  Esta fun��o efetua de fato a transa��o, utilizando os par�metros que foram previamente
                      definidos atrav�s de PTI_EFT_AddParam.
                      Esta fun��o � blocante, e somente retorna ap�s a conclus�o (ou falha) da transa��o.

    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).

    Saida          :  Nenhuma.

    Retorno(piRet) :  PTIRET_OK          Opera��o bem-sucedida (para venda, significa transa��o aprovada).
                      PTIRET_INVPARAM    Par�metro inv�lido passado � fun��o
                      PTIRET_NOCONN      O terminal est� offline.
                      PTIRET_BUSY        O terminal est� ocupado processando outro comando
                      PTIRET_EFTERR      A transa��o foi realizada, entretanto falhou
   }
//=========================================================================================================
  function PTI_EFT_Exec (pszTerminalId:AnsiString; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';




//===========================================================================================================
  {
    Function       :  PTI_EFT_GetInfo

    Descri��o      :  A Automa��o Comercial deve chamar esta fun��o iterativamente para recuperar
                      os dados relativos � transa��o que foi realizada (com ou sem sucesso) pelo terminal.
                      Esta fun��o retorna imediatamente

    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).

                      iInfo          Identificador da informa��o a ser obtida,
                                     conforme o cap�tulo �TAG�s de entrada e sa�da�.

                      uiBufLen       Tamanho (em bytes) do buffer referenciado pelo ponteiro pszValue

    Saida          :  pszValue       Informa��o recuperada (final nulo).

    Retorno(piRet) :  PTIRET_OK          Opera��o bem-sucedida, informa��o retornada
                      PTIRET_INVPARAM    Par�metro inv�lido passado � fun��o.
                      PTIRET_BUFOVRFLW   O tamanho do dado � maior que uiBufLen.
                      PTIRET_NOCONN      O terminal est� offline
                      PTIRET_BUSY        O terminal est� ocupado processando outro comando
                      PTIRET_NODATA      Informa��o n�o dispon�vel.
   }
//===========================================================================================================
  function PTI_EFT_GetInfo (pszTerminalId:AnsiString; iInfo:Int16;  uiBufLen:UInt16; var szValue:PSZ_GetpszValue;
                            var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';



//==============================================================================================================================
  {
    Function       :  PTI_EFT_PrintReceipt

    Descri��o      : Esta fun��o faz com que o terminal imprima o comprovante da �ltima transa��o realizada.
                     A Automa��o Comercial pode optar por:
                    . Utilizar esta fun��o para imprimir uma ou ambas as vias (estabelecimento e/ou portador do
                      cart�o) do comprovante de pagamento;
                    . Recuperar o conte�do do comprovante atrav�s de PTI_EFT_GetInfo e:
                      .Imprimir uma ou ambas as vias em uma impressora dedicada
                      .Enviar a c�pia do portador do cart�o por e-mail ou outro tipo de mensageria;
                    Nota: a via do estabelecimento deve sempre ser impressa quando PWINFO_CHOLDVERIF
                    (recuperado atrav�s de PTI_EFT_GetInfo) indicar que a assinatura do portador do cart�o � requerida.

    Entrada         : pszTerminalId  Identificador �nico do terminal (final nulo).

                      iCopies        Soma dos valores da tabela abaixo.

    Saidas          : pszValue Informa��o recuperada (final nulo).

    Retorno         : PTIRET_OK         Bem-sucedida, impress�o iniciada
                      PTIRET_INVPARAM   Par�metro inv�lido passado � fun��o.
                      PTIRET_NOCONN     O terminal est� offline
                      PTIRET_BUSY       O terminal est� ocupado processando outro comando
                      PTIRET_NODATA     N�o h� recibo a ser impresso
                      PTIRET_PRINTERR   Erro na impressora
                      PTIRET_NOPAPER    Impressora sem papel

                      Identificadores da c�pia do recibo:
                      ===================================
                      Nome                  Valor     Descri��o
                      ================      =====     ======================
                      PTIPRN_MERCHANT         1       Via do estabelecimento
                      PTIPRN_CHOLDER          2       Via do portador do cart�o


   }
//==============================================================================================================================
  function PTI_EFT_PrintReceipt (pszTerminalId:AnsiString; iCopies:Int16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





//============================================================================================================================
  {
    Function       :  PTI_EFT_Confirm

    Descri��o      :  Qualquer transa��o financeira bem-sucedida (PTI_EFT_Exec retorna PTIRET_OK) deve ser
                      confirmada pela Automa��o Comercial atrav�s desta fun��o para assegurar a integridade da
                      transa��o entre todas as partes (Automa��o Comercial e registro fiscais, terminal, adquirente,
                      emissor e portador do cart�o).
                      M�ltiplas transa��es podem ser realizadas simultaneamente por diversos terminais, entretanto, para
                      cada terminal, a transa��o deve ser confirmada antes de outra ser iniciada. Em cada momento,
                      somente pode haver no m�ximo uma �nica transa��o pendente para cada terminal.
                      Para minimizar cen�rios de desfazimento, � recomend�vel que a Automa��o Comercial confirme a
                      transa��o t�o logo seja poss�vel. Caso PTI_EFT_Exec retorne PTIRET_OK e a Automa��o Comercial
                      n�o confirmar a transa��o imediatamente, esta deve ser armazenada em mem�ria n�o vol�til
                      (arquivo) com todas as informa��es necess�rias para confirmar ou desfazer a transa��o em caso de
                      queda de energia que ocorra ap�s esse momento.
                      Eventos que podem levar a um desfazimento da transa��o s�o:
                      . Falha na impressora (quando a assinatura do portador do cart�o for requerida);
                      . Mercadoria n�o pode ser entregue (mecanismo do dispensador falha ou equivalente);
                      . Falta de energia (portador do cart�o utilizou um m�todo de pagamento alternativo antes da volta
                        da energia).


    Entrada        :  pszTerminalId  Identificador �nico do terminal (final nulo).

                      iStatus        Status final da transa��o, conforme detalhado abaixo.

    Saida          :  Nenhuma.

    Retorno(piRet) :  PTIRET_OK         Confirma��o realizada.
                      PTIRET_INVPARAM   Par�metro inv�lido passado � fun��o.

                      Lista de poss�veis status final para a transa��o:
                      =================================================
                      Nome             Valor      Descri��o
                      =============    =====      =====================
                      PTICNF_SUCCESS     1        Transa��o confirmada
                      PTICNF_PRINTERR    2        Erro na impressora, desfazer a transa��o.
                      PTICNF_DISPFAIL    3        Erro com o mecanismo dispensador, desfazer a transa��o.
                      PTICNF_OTHERERR    4        Outro erro, desfazer a transa��o.
   }
//============================================================================================================================
  function  PTI_EFT_Confirm (pszTerminalId:AnsiString; iStatus:Int16; var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';



//====================================================================================================
  {
    Funcao     :   PTI_PrnSymbolCode

    Descricao  :   Esta fun��o imprime um c�digo de barras ou QR code na impressora do terminal.

    Entradas   :   pszTerminalId  :  Identificador �nico do terminal (final nulo).
                   pszMsg         :  C�digo a ser impresso.
                   iSymbology     :  Tipo de c�digo, conforme tabela abaixo.

    Saidas     :   Nenhuma.

    Retorno    :   PTIRET_OK          : Opera��o bem sucedida.
                   PTIRET_INVPARAM    : Par�metro inv�lido passado � fun��o.
                   PTIRET_INTERNALERR : Erro interno da biblioteca de integra��o.
                   PTIRET_NOCONN      : O terminal est� offline.
                   PTIRET_BUSY        : O terminal est� ocupado processando outro comando.

                   Tabela de tipos de c�digo:
                   ==========================
                   Nome            Valor   Descri��o
                   ============    =====   ===============
                                           C�digo de barras padr�o 128.
                   CODESYMB_128      2     C�digo de barras padr�o 128. Pode-se utilizar aproximadamente
                                           31 caracteres alfanum�ricos.

                                           C�digo de barras padr�o ITF
                   CODESYMB_ITF      3     Pode-se utilizar aproximadamente
                                           30 caracteres alfanum�ricos.

                                           QR Code. Com aceita��o de
                   CODESYMB_QRCODE   4     aproximadamente 600 caracteres
                                           alfanum�ricos.
   }
//====================================================================================================
  function  PTI_PrnSymbolCode (pszTerminalId:AnsiString; pszMsg:AnsiString; iSymbology:Int16;
                               var piRet:SHORT):Int16; stdCall; External 'PTI_DLL.dll';





implementation

uses  uLib02, Principal;


var

   sziRet : PSZ_GetiRet;

   szTerminalId:  PSZ_GetpszTerminalId;
   szModel: PSZ_GetpszModel;
   szMAC: PSZ_GetpszMAC;
   szSerNum: PSZ_GetpszSerNum;

   szValue: PSZ_GetpszValue;




//====================================
// Aguarda Conex�o de POS
//====================================
function TPOSPGWLib.Conexao: Integer;
var
 iRet:Int16;
 IRetorno:Integer;
 ret : SHORT;
 I:Integer;

 caminho:string;

begin


     isRunning := True;


     I := 0;


     while I < 10000 do
     begin

         // Indica Finalizar Thread
         if (FPrincipal.Wfinalizar = 1) then
             begin
                Exit;
             end;

         ret := 99;

         // Executa metodo de espera por Nova Conex�o
         PTI_ConnectionLoop(szTerminalId, szModel, szMAC, szSerNum, Ret);

         // Nova Conex�o encontrada
         if(Ret = eCclasse.PTIRET_NEWCONN) then
            begin

               WszTerminalId := szTerminalId[0].pszTerminalId;
               WszModel      := szModel[0].pszModel;
               WszMAC        := szMAC[0].pszMAC;
               WszSerNum     := szSerNum[0].pszSerNum;


               result := Ret;

               Break;

               Exit;

            end;



        Sleep(300);

     end;




end;



//=======================================================================
// Confirma��o de Transa��o, usado para Transa��es pendentes ou com erro
//=======================================================================
function TPOSPGWLib.confirmacao(Wterminal: AnsiString): Integer;
var
 ret : SHORT;
 tret: SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 retorno:AnsiString;
begin

        // Limpa buffer de teclas pressionadas
        PTI_ClearKey(WTerminal, ret);


        //Exemplo de menu:
        PTI_StartMenu(WTerminal, ret);
        PTI_AddMenuOption(WTerminal, 'SIM', ret);
        PTI_AddMenuOption(WTerminal, 'NAO', ret);
        PTI_ExecMenu(WTerminal, 'CONFIRMA TRANSACAO?', 30, puiSelection, ret);

        // Qual foi selecionado
        if (puiSelection = 0)then
           begin
            PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_SUCCESS, ret);
            MandaMemo('Transa��o Confirmada: PTICNF_SUCCESS ');
           end
        else
           begin
            PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_OTHERERR, ret);
            MandaMemo('Transa��o Confirmada: PTICNF_OTHERERR ');
           end;



end;










constructor TPOSPGWLib.Create;
begin

  // POSenums   := TCPOSEnums.Create;

end;



//=============================================
//  Desconectar Terminal, apenas de exemplo.
//=============================================
function TPOSPGWLib.Desconectar: Integer;
var
 ret : SHORT;
 key : SHORT;
begin

    // Mostra ao usu�rio que o Terminal ser� desconectado
    PTI_Display(WszTerminalId, 'Desconectar ', ret);

    // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
    PTI_WaitKey(WszTerminalId, 5, key, ret);

    MandaMemo('');
    MandaMemo('Terminal Desconectado - PTI_Disconnect');
    MandaMemo('');

    PTI_Disconnect(WszTerminalId, 0);



end;


destructor TPOSPGWLib.Destroy;
begin
  inherited;
end;


//==============================================
  {
      Finaliza uso da Biblioteca
  }
//==============================================
function TPOSPGWLib.Finalizar: Integer;
begin

    MandaMemo('');
    MandaMemo('Uso da biblioteca de integra��o foi Encerrado');
    FPrincipal.Wfinalizar := 1;
    Application.ProcessMessages;

    PTI_End();

end;

//==============================================
  {
      Inicializa Biblioteca
  }
//==============================================
function TPOSPGWLib.Init: Integer;
var
 ret : SHORT;
 caminho:string;
 retorno:string;
begin

    currentNumberOfTerminals := 0;
    Caminho := ExtractFilePath(ParamStr(0)) + pasta;
    appWorkingPath := caminho;
    appListeningPort := 10000;
    maxNumberOfTerminals := 50;
    msgIdle := 'APLICACAO TESTE';
    appCompany := 'NTK Solutions';
    appVersion := 'Aplicacao exemplo ' + POSenums.PGWEBLIBTEST_VERSION;
    appCapabilities := '63';
    appuiAutoDiscSec := 0;


    PTI_Init(appCompany, appVersion, appCapabilities, appWorkingPath, appListeningPort, maxNumberOfTerminals,msgIdle, appuiAutoDiscSec, ret);

    if (ret  <>  POSenums.PTIRET_OK) then
        begin
            // ShowMessage('ERRO AO INICIAR DLL: ' + IntToStr(ret));
        end;


    MandaMemo('PTI_Init ');

    MandaMemo('');

    MandaMemo('pszPOS_Company......: ' + appCompany);
    MandaMemo('pszPOS_Version......: ' + appVersion);
    MandaMemo('pszPOS_Capabilities.: ' + appCapabilities);
    MandaMemo('pszDataFolder.......: ' + appWorkingPath);
    MandaMemo('uiTCP_Port..........: ' + IntToStr(appListeningPort));
    MandaMemo('uiMaxTerminals......: ' + IntToStr(maxNumberOfTerminals));
    MandaMemo('pszWaitMsg..........: ' + msgIdle);
    MandaMemo('uiAutoDiscSec.......: ' + IntToStr(appuiAutoDiscSec));

    MandaMemo('');

    PrintReturnDescription(ret, '');




    Result := ret;


end;


//==============================================
  {
      Atualiza Log da Aplica��o
  }
//==============================================
function TPOSPGWLib.MandaMemo(Descr:string): integer;
begin

    if (FPrincipal.Memo1.Visible = False) then
       begin
         FPrincipal.Memo1.Visible := True;
       end;
         FPrincipal.Memo1.Lines.Add(Descr);

    Result := 0;

end;


//=================================================
//  Menu de Captura de dados digitados no terminal
//=================================================
function TPOSPGWLib.menucaptura(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin

     I := 0;

     while I < 10 do
     begin

         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;
         retorno := 0;

         PTI_ClearKey(WTerminal, ret);

         // Inicia fun��o de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona op��o 1 do menu:
         PTI_AddMenuOption(WTerminal, 'CPF Mascarado', ret);
         // Adiciona op��o 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'CPF Nao Mascarado', ret);
         // Adiciona op��o 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Retornar', ret);
         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);

         //========================================================
         // Verifica tempo default de espera da conex�o(TIMEOUT),
         // ao esgotar este tempo, a conex�o � finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);

               retorno := 1;

               Break;

             end;


         // Verifica op��o escolhida
         if(puiSelection = 0) then
            begin
               iRet :=  PTI_GetData(WTerminal, 'CPF C/Mascara'+chr(13), '@@@.@@@.@@@-@@', 11, 11, false, false, true, 30, pszData, 2, ret);
               WpszData := pszData[0].pszData;
               MandaMemo('');
               MandaMemo('CPF Com Mascara Capturado: ' + WpszData + ' - Terminal: ' + WTerminal);
               MandaMemo('');
               //Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                PTI_WaitKey(WszTerminalId, 5, key, ret);
               // Limpa Captura de Dados;
               pszData := wLimpapszdata;
            end
         else if (puiSelection = 1) then
            begin
               iRet :=  PTI_GetData(WTerminal, 'CPF S/Mascara'+chr(13), '@@@.@@@.@@@-@@', 11, 11, true, false, false, 30, pszData, 2, ret);
               WpszData := pszData[0].pszData;
               MandaMemo('');
               MandaMemo('CPF S/Mascara Capturado: ' + WpszData + ' - Terminal: ' + WTerminal);
               MandaMemo('');
               //Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                PTI_WaitKey(WTerminal, 5, key, ret);
               // Limpa Captura de Dados;
               pszData := wLimpapszdata;
            end
         else if (puiSelection = 2) then
            begin
               Break;
            end;


     end;


     Result := retorno;

end;

//==================================================
//  Menu de Impress�o de Codigo de Barras ou QRCode
//==================================================
function TPOSPGWLib.menucodigos(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin

     I := 0;

     while I < 10 do
     begin

         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;
         retorno := 0;

         PTI_ClearKey(WTerminal, ret);

         // Inicia fun��o de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona op��o 1 do menu:
         PTI_AddMenuOption(WTerminal, 'Imprimir QR Code', ret);
         // Adiciona op��o 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'Imprimir C.Barras', ret);
         // Adiciona op��o 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Retornar', ret);
         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);

         //========================================================
         // Verifica tempo default de espera da conex�o(TIMEOUT),
         // ao esgotar este tempo, a conex�o � finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);

               retorno := 1;

               Break;

             end;


         // verifica op��o escolhida
         if(puiSelection = 0) then
            begin
                //Impress�o de QR Code
                  MandaMemo('');
                  MandaMemo('Escolheu QR Code');
                  PTI_PrnSymbolCode(WTerminal, 'http://www.ntk.com.br', 4, ret);

                  //Avan�a algumas linhas do papel da impressora:
                  PTI_PrnFeed(WTerminal, ret);

            end
         else if (puiSelection = 1) then
            begin
                //Impress�o de c�digo de barras:
                  MandaMemo('');
                  MandaMemo('Escolheu Codigo de Barras');
                  PTI_PrnSymbolCode(WTerminal, '0123456789', 2, ret);

                  //Avan�a algumas linhas do papel da impressora:
                  PTI_PrnFeed(WTerminal, ret);

            end
         else if (puiSelection = 2) then
            begin
               Break;
            end;



     end;


     Result := retorno;

end;

//=============================================
//  Menu de Op��es de Impress�o
//=============================================
function TPOSPGWLib.menuimpressao(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin

     I := 0;


     while I < 10 do
     begin

         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;
         retorno := 0;



         PTI_ClearKey(WTerminal, ret);

         // Inicia fun��o de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona op��o 1 do menu:
         PTI_AddMenuOption(WTerminal, 'PrintReceipt', ret);
         // Adiciona op��o 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'Display', ret);
         // Adiciona op��o 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Print', ret);
         // Adiciona op��o 4 ao menu:
         PTI_AddMenuOption(WTerminal, 'PrnSymbolcode', ret);
         // Adiciona op��o 5 ao menu:
         PTI_AddMenuOption(WTerminal, 'Retornar', ret);

         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);

         //========================================================
         // Verifica tempo default de espera da conex�o(TIMEOUT),
         // ao esgotar este tempo, a conex�o � finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);

               retorno := 1;

               Break;

             end;


               // verifica op��o escolhida
               if (puiSelection = 0)then
                   begin
                   // Imprimir recibo
                      PTI_EFT_PrintReceipt(WTerminal, 3, ret);
                      if (ret = eCclasse.PTIRET_NODATA) then
                         begin
                            MandaMemo('');
                            MandaMemo('N�o Existe Recibo a ser Impresso');
                            PTI_Display(WTerminal, 'Nao Existe Recibo: ', ret);
                            // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                            PTI_WaitKey(WTerminal, 5, key, ret);
                         end;
                      if (ret = eCclasse.PTIRET_NOPAPER) then
                         begin
                            MandaMemo('');
                            MandaMemo('Impressora sem Papel');
                            PTI_Display(WTerminal, 'Impressora sem Papel: ', ret);
                            // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                            PTI_WaitKey(WTerminal, 5, key, ret);
                         end;

                   end

               else if (puiSelection = 1) then
                    begin
                   //Imprimir na Tela
                     PTI_Display(WTerminal, 'Exemplo PTI_Display', ret);
                   //Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                     PTI_WaitKey(WTerminal, 5, key, ret);
                    end
               else if (puiSelection = 2) then
                    begin
                       // imprime na Ipressora
                       // Limpa Captura de Dados;
                          pszData := wLimpapszdata;
                       // Captura um Numero
                          iRet :=  PTI_GetData(WTerminal, 'Numero Para Imprimir'+chr(13), '@@@@@@', 1, 6, false, false, true, 30, pszData, 2, ret);
                       // Numero Digitado:
                          WpszData :=  'PTI_Print Informado: ' + pszData[0].pszData;
                       // Impress�o do Numero:
                          PTI_Print(WTerminal, WpszData, ret);

                          MandaMemo('');
                          MandaMemo(WpszData + ' - Terminal: ' + WTerminal);
                          MandaMemo('');

                       // Avan�a Papel na Impressora
                          PTI_PrnFeed (WTerminal, ret);

                    end
               else if (puiSelection = 3) then
                    begin
                        begin
                           //Imprimir codigo de barras ou QRCode
                            retorno := menucodigos(WTerminal);
                            if (retorno = 1) then
                                Break;
                        end;
                    end
               else if (puiSelection = 4) then
                   // Sair do Menu
                      Break;

     end;


          Result := retorno;

end;


//=============================================
//  Menu de Opera��es:
//  Venda, Cancelamento e Administrativo
//=============================================
function TPOSPGWLib.menuoperacoes(WTerminal:AnsiString):Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin
     I := 0;


     while I < 10 do
     begin


         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;
         retorno := 0;

         PTI_ClearKey(WTerminal, ret);

         // Inicia fun��o de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona op��o 1 do menu:
         PTI_AddMenuOption(WTerminal, 'Venda', ret);
         // Adiciona op��o 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'Cancelamento', ret);
         // Adiciona op��o 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Administrativo', ret);
         // Adiciona op��o 4 ao menu:
         PTI_AddMenuOption(WTerminal, 'Retornar', ret);
         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);

         //========================================================
         // Verifica tempo default de espera da conex�o(TIMEOUT),
         // ao esgotar este tempo, a conex�o � finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);

               retorno := 1;

               Break;

             end;

         // verifica op��o escolhida
         if (puiSelection = 0)then
             operacaovenda(WTerminal)
         else if (puiSelection = 1) then
             operacaocancela(WTerminal)
         else if (puiSelection = 2) then
             operacaoadmin(WTerminal)
         else if (puiSelection = 3) then
             Break;


     end;


     Result := retorno;

end;


//=============================================
//  Menu Principal da Aplica��o
//=============================================
function TPOSPGWLib.menuprincipal(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 I:Integer;
 retorno:Integer;
begin

     I := 0;


     while I < 10 do
     begin


         key := 99;
         ret := 99;
         status := 99;
         puiSelection := -1;


         PTI_ClearKey(WTerminal, ret);

         // Inicia fun��o de menu:
         PTI_StartMenu(WTerminal, ret);

         // Adiciona op��o 1 do menu:
         PTI_AddMenuOption(WTerminal, 'Operacoes', ret);
         // Adiciona op��o 2 ao menu:
         PTI_AddMenuOption(WTerminal, 'Captura de Dados', ret);
         // Adiciona op��o 3 ao menu:
         PTI_AddMenuOption(WTerminal, 'Impressao', ret);
         // Adiciona op��o 4 ao menu:
         PTI_AddMenuOption(WTerminal, 'Desconectar', ret);
         // Executa o menu:
         PTI_ExecMenu(WTerminal, 'SELECIONE A OPCAO', 30, puiSelection, ret);


         //========================================================
         // Verifica tempo default de espera da conex�o(TIMEOUT),
         // ao esgotar este tempo, a conex�o � finalizada!,
         // mostrando mensagem na tela do POS
         //========================================================
         if (ret = POSenums.PTIRET_TIMEOUT) then
             begin
               PTI_Display(WTerminal, 'Tempo de Espera' + chr(13) + 'Esgotado(TIMEOUT)', ret);
               // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
               PTI_WaitKey(WTerminal, 5, key, ret);
               Break;
             end;



         // verifica op��o escolhida
         if (puiSelection = 0)then
             begin
               retorno := menuoperacoes(WTerminal);
               if (retorno = 1) then
                  Break;
             end
         else if (puiSelection = 1) then
             begin
               retorno := menucaptura(WTerminal);
               if (retorno = 1) then
                  Break;
             end
         else if (puiSelection = 2) then
             begin
              retorno := menuimpressao(WTerminal);
               if (retorno = 1) then
                  Break;
             end
         else if (puiSelection = 3) then
             begin
                Break;
             end;


     end;


    // mensagem de desocectado na aplica��o
    MandaMemo('');
    MandaMemo('Terminal: ' + WTerminal + ' Desconectado.');
    MandaMemo('');

    // desconecta terminal POS
    PTI_Disconnect(WTerminal, 0);


    Exit;



end;

//========================================================
//  Executa Processo em uma nova Conex�o
//========================================================
function TPOSPGWLib.NovaConexao: Integer;
var
 ret : SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 retorno:AnsiString;
 I:Integer;

begin

     key := 99;
     ret := 99;
     status := 99;
     puiSelection := -1;
     I := 0;

     //Mostra ao usu�rio o identificador do terminal que conectou:
     PTI_Display(WszTerminalId, 'TERMINAL '  + WszTerminalId +   chr(13) +  ' CONECTADO', ret);

     MandaMemo('');
     MandaMemo('Terminal Conectado: ' + WszTerminalId );

     // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
     PTI_WaitKey(WszTerminalId, 5, key, ret);

     // Consulta informa��es do terminal atrav�s da fun��o PTI_CheckStatus:
     PTI_CheckStatus(WszTerminalId, status, WszModel, WszMAC, WszSerNum, ret);

     // Mostra ao usu�rio os dados obtidos atrav�s da fun��o PTI_CheckStatus:
     PTI_Display(WszTerminalId, 'SERIAL: ' + WszSerNum + chr(13) + 'MAC: ' + WszMAC + chr(13) + 'MODELO: ' + WszModel + chr(13) +'Status: ' + IntToStr(status), ret);

     MandaMemo('Serial: ' + WszSerNum);
     MandaMemo('MAC   : ' + WszMAC);
     MandaMemo('Modelo: ' + WszModel);


     // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
     PTI_WaitKey(WszTerminalId, 5, key, ret);


     // Menu Principal
     menuprincipal(WszTerminalId);


     Exit;




     //================================



end;



//===============================================================
{
     Opera��o Administrativa
}
//===============================================================
function TPOSPGWLib.operacaoadmin(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
begin

    //Limpa Captura de Dados;
      pszData := wLimpapszdata;

    //Inicia transa��o Admin:
      PTI_EFT_Start(WTerminal, eCclasse.PWOPER_ADMIN, ret);

    //Executa transa��o:
      MandaMemo('Executou Transa��o Administrativa: ');
      PTI_EFT_Exec(WTerminal, ret);

      if (ret = eCclasse.PTIRET_OK) then
         begin
             // OK
         end
      else
         begin
             // N�o retornou OK, vai para confirma��o, pode existir transa��o pendente ou com erro.
             confirmacao(WTerminal);
         end;


      Exit;



end;



//=========================================================================
  {
     Opera��o de Cancelamento
  }
//=========================================================================
function TPOSPGWLib.operacaocancela(WTerminal: AnsiString): Integer;
var
  iRet: Int16;
  WpszData: AnsiString;
  RET:SHORT;
  key : SHORT;
  I:Integer;
  puiSelection:ShortInt;
  WData:string;
  retorno:AnsiString;
begin



            //Inicia transa��o de Cancelamento:
             PTI_EFT_Start(WTerminal, eCclasse.PWOPER_SALEVOID, ret);

             if (ret = eCclasse.PTIRET_CANCEL) then
                 begin
                   MandaMemo('Cancelamento Cancelado pela aplica��o: ');
                   PTI_Display(WTerminal, 'Cancelado pela aplicacao: ', ret);
                   // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
                   PTI_WaitKey(WTerminal, 5, key, ret);
                   Exit;
                 end;


            //Executa transa��o:
              PTI_EFT_Exec(WTerminal, ret);



            if (ret = 0)then           // Transa��o autorizada OK
               begin


                    // Mostra valores armazenados em todos PWINFO_
                    PrintResultParams(WTerminal);

                    // Impress�o do comprovante da transa��o:
                    PTI_EFT_PrintReceipt(WTerminal, 3, ret);

                    // sinal sonoro
                    PTI_Beep(WTerminal, 0, ret);

                    // Menu de Confirma��o:
                    PTI_StartMenu(WTerminal, ret);
                    PTI_AddMenuOption(WTerminal, 'SIM', ret);
                    PTI_AddMenuOption(WTerminal, 'NAO', ret);
                    PTI_ExecMenu(WTerminal, 'CONFIRMAR TRANSACAO?', 30, puiSelection, ret);

                    if (puiSelection = 0)then
                       begin
                        PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_SUCCESS, ret);
                       end
                    else
                       begin
                        PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_OTHERERR, ret);
                       end;

               end
            else
               begin

                    // Transa��o Pendente ou Falhou

                    // Mostra valores armazenados em todos PWINFO_???
                    PrintResultParams(WTerminal);

                    // retorno de mensagem
                    PTI_EFT_GetInfo(WTerminal, eCclasse.PWINFO_RESULTMSG, SizeOf(szValue), szValue, ret);

                    retorno := szValue[0].pszValue;
                    MandaMemo('');
                    MandaMemo(retorno);

                    // metodo de confirma��o para o caso de transa��o pendente ou ter falhado
                    confirmacao(WTerminal);

               end;





end;


//=========================================================================
  {
     Opera��o de Venda
  }
//=========================================================================
function TPOSPGWLib.operacaovenda(WTerminal: AnsiString): Integer;
var
 ret : SHORT;
 tret: SHORT;
 key : SHORT;
 status : SHORT;
 puiSelection:ShortInt;
 iRet: Int16;
 WpszData: AnsiString;
 wLimpapszdata:PSZ_GetpszData;
 pszData: PSZ_GetpszData;
 retorno:AnsiString;
begin


     // Limpa Captura de Dados;
       pszData := wLimpapszdata;

     //=================================================
     // Inicia Transa��o de Venda:

    //Obt�m do usu�rio o valor da transa��o:
     MandaMemo('Digite O Valor do Pagamento:');
     iRet :=  PTI_GetData(WTerminal, 'DIGITE VALOR PAGAMENTO ' +chr(13), '@@@.@@@,@@', 3, 8, false, false, false, 30, pszData, 2, ret);

     if (ret = eCclasse.PTIRET_CANCEL) then
         begin
           MandaMemo('Venda Abortada pela aplica��o: ');
           PTI_Display(WTerminal, 'Venda Abortada ' + chr(13) + 'pela Aplicacao', ret);
           // Usa fun��o de aguardar tecla para deixar mensagem anterior na tela por 5 segundos:
           PTI_WaitKey(WTerminal, 5, key, ret);
           Exit;
         end;

    //Inicia transa��o de pagamento:
     PTI_EFT_Start(WTerminal, eCclasse.PWOPER_SALE, ret);

    //Insere par�metro "moeda":   986 = Real
     PTI_EFT_AddParam(WTerminal, eCclasse.PWINFO_CURRENCY, '986', ret);

    //Recupera Valor Total Digitado;
     WpszData := pszData[0].pszData;
     MandaMemo('Valor Informado: '  + WpszData + ' - Terminal: ' + WTerminal);
     MandaMemo('');

     // Adiciona Parametro Valor Total
     PTI_EFT_AddParam(WTerminal, eCclasse.PWINFO_TOTAMNT, WpszData, ret);

    //Executa transa��o:
     MandaMemo('Executa Transa��o de Venda: ');
     PTI_EFT_Exec(WTerminal, ret);


    if (ret = 0)then           // Transa��o autorizada OK
       begin

              // Mostra valores armazenados em todos PWINFO_???
              PrintResultParams(WTerminal);


              //Impress�o de c�digo de barras:
              PTI_PrnSymbolCode(WTerminal, '0123456789', 2, ret);

              //Impress�o de QR Code
              PTI_PrnSymbolCode(WTerminal, 'http://www.ntk.com.br', 4, ret);

              //Avan�a algumas linhas do papel da impressora:
              PTI_PrnFeed(WTerminal, ret);

              //Impress�o do comprovante da transa��o:
              PTI_EFT_PrintReceipt(WTerminal, 3, ret);


              PTI_Beep(WTerminal, 0, ret);

              // Limpa buffer de teclas pressionadas
              PTI_ClearKey(WTerminal, ret);


              //Exemplo de menu:
              PTI_StartMenu(WTerminal, ret);
              PTI_AddMenuOption(WTerminal, 'SIM', ret);
              PTI_AddMenuOption(WTerminal, 'NAO', ret);
              PTI_ExecMenu(WTerminal, 'CONFIRMA TRANSACAO?', 30, puiSelection, ret);

              if (puiSelection = 0)then
                 begin
                  PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_SUCCESS, ret);
                 end
              else
                 begin
                  PTI_EFT_Confirm(WTerminal, eCclasse.PTICNF_OTHERERR, ret);
                 end;

       end
    else
       begin
            // Transa��o Pendente ou Falhou

            // Mostra valores armazenados em todos PWINFO_???
            PrintResultParams(WTerminal);

            // recupera retorno de mensagem
            PTI_EFT_GetInfo(WTerminal, eCclasse.PWINFO_RESULTMSG, SizeOf(szValue), szValue, ret);

            retorno := szValue[0].pszValue;
            MandaMemo('');
            MandaMemo(retorno);

            // metodo de confirma��o para o caso de pendente ou falhou
            confirmacao(WTerminal);


       end;




    Exit;




end;

//=====================================================================================*\
  {
     Funcao     :  PrintResultParams

     Descricao  :  Esta fun��o exibe na tela todas as informa��es de resultado dispon�veis
                   no momento em que foi chamada.

     Entradas   :  nao ha.

     Saidas     :  nao ha.

     Retorno    :  nao ha.
  }
//=====================================================================================*/
function TPOSPGWLib.PrintResultParams(WterminalID: AnsiString): Integer;
var
  I:Integer;
  Ir:Integer;
  volta:string;

  iRet:Integer;
  ret:SHORT;
  retorno:AnsiString;
  retornoMemo:AnsiString;
  WTexto:string;
  WTextoMemo:string;
  Wmax:Integer;

begin

   I := 0;
   WTexto := '';
   Wmax := 32000;

   while I < Wmax  do
   begin

       volta :=  pszGetInfoDescription(I);
       if (volta = 'PWINFO_XXX') then
          begin
            I := I+1;
            Continue;
          end;


       PTI_EFT_GetInfo(WterminalID, I, SizeOf(szValue), szValue, ret);

       if (ret = eCclasse.PTIRET_OK) then
           begin
             retorno := szValue[0].pszValue;
             WTexto := WTexto + volta + ' = ' + retorno + chr(13);
             WTextoMemo := WTextoMemo + volta + ' = ' + retorno + chr(13)+chr(10);
           end;

       I := I+1;

   end;


   //Impress�o de texto:
   PTI_Print(WterminalID, WTexto, ret);

   MandaMemo('');
   MandaMemo(WTextoMemo);


end;


//=====================================================================================*\
  {
   Funcao     :  PrintReturnDescription

   Descricao  :  Esta fun��o recebe um c�digo PTIRET_XXX e imprime na tela a sua descri��o.

   Entradas   :  iResult :   C�digo de resultado da transa��o (PTIRET_XXX).

   Saidas     :  nao ha.

   Retorno    :  nao ha.
  }
//=====================================================================================*/
function TPOSPGWLib.PrintReturnDescription(iReturnCode:Integer;
  pszDspMsg:string):Integer;
  var
    I : integer;
  begin

       case iReturnCode of


         POSenums.PTIRET_OK:
           begin
            MandaMemo('PTIRET_OK');
           end;

         POSenums.PTIRET_INVPARAM:
           begin
            MandaMemo('PTIRET_INVPARAM');
           end;

         POSenums.PTIRET_NOCONN:
           begin
            MandaMemo('PTIRET_NOCONN');
           end;

         POSenums.PTIRET_BUSY:
           begin
            MandaMemo('PTIRET_BUSY');
           end;

         POSenums.PTIRET_TIMEOUT:
           begin
            MandaMemo('PTIRET_TIMEOUT');
           end;

         POSenums.PTIRET_CANCEL:
           begin
            MandaMemo('PTIRET_CANCEL');
           end;

         POSenums.PTIRET_NODATA:
           begin
            MandaMemo('PTIRET_NODATA');
           end;

         POSenums.PTIRET_BUFOVRFLW:
           begin
            MandaMemo('PTIRET_BUFOVRFLW');
           end;

         POSenums.PTIRET_SOCKETERR:
           begin
            MandaMemo('PTIRET_SOCKETERR');
           end;

         POSenums.PTIRET_WRITEERR:
           begin
            MandaMemo('PTIRET_WRITEERR');
           end;

         POSenums.PTIRET_EFTERR:
           begin
            MandaMemo('PTIRET_EFTERR');
           end;

         POSenums.PTIRET_INTERNALERR:
           begin
            MandaMemo('PTIRET_INTERNALERR');
           end;

         POSenums.PTIRET_PROTOCOLERR:
           begin
            MandaMemo('PTIRET_PROTOCOLERR');
           end;

         POSenums.PTIRET_SECURITYERR:
           begin
            MandaMemo('PTIRET_SECURITYERR');
           end;

         POSenums.PTIRET_PRINTERR:
           begin
            MandaMemo('PTIRET_PRINTERR');
           end;

         POSenums.PTIRET_NOPAPER:
           begin
            MandaMemo('PTIRET_NOPAPER');
           end;

         POSenums.PTIRET_NEWCONN:
           begin
            MandaMemo('PTIRET_NEWCONN');
           end;

         POSenums.PTIRET_NONEWCONN:
           begin
            MandaMemo('PTIRET_NONEWCONN');
           end;

         POSenums.PTIRET_NOTSUPPORTED:
           begin
            MandaMemo('PTIRET_NOTSUPPORTED');
           end;

         POSenums.PTIRET_CRYPTERR:
           begin
            MandaMemo('PTIRET_CRYPTERR');
           end;

      else

         begin
           begin
            MandaMemo('OUTRO ERRO: ' + IntToStr(iReturnCode));
           end;

         end;






       end;



  end;




//=====================================================================================*\
  {
   Funcao     :  pszGetInfoDescription

   Descricao  :  Esta fun��o recebe um c�digo PWINFO_XXX e retorna uma string com a
                 descri��o da informa��o representada por aquele c�digo.

   Entradas   :  wIdentificador :  C�digo da informa��o (PWINFO_XXX).

   Saidas     :  nao ha.

   Retorno    :  String representando o c�digo recebido como par�metro.
  }
//=====================================================================================*/
  function TPOSPGWLib.pszGetInfoDescription(wIdentificador:Integer):string;
  begin

       case wIdentificador of

        eCclasse.PWINFO_OPERATION           :  Result := 'PWINFO_OPERATION';
        eCclasse.PWINFO_MERCHANTCNPJCPF     :  Result := 'PWINFO_MERCHANTCNPJCPF';
        eCclasse.PWINFO_TOTAMNT             :  Result := 'PWINFO_TOTAMNT';
        eCclasse.PWINFO_CURRENCY            :  Result := 'PWINFO_CURRENCY';
        eCclasse.PWINFO_FISCALREF           :  Result := 'PWINFO_FISCALREF';
        eCclasse.PWINFO_CARDTYPE            :  Result := 'PWINFO_CARDTYPE';
        eCclasse.PWINFO_PRODUCTNAME         :  Result := 'PWINFO_PRODUCTNAME';
        eCclasse.PWINFO_DATETIME            :  Result := 'PWINFO_DATETIME';
        eCclasse.PWINFO_REQNUM              :  Result := 'PWINFO_REQNUM';
        eCclasse.PWINFO_AUTHSYST            :  Result := 'PWINFO_AUTHSYST';
        eCclasse.PWINFO_VIRTMERCH           :  Result := 'PWINFO_VIRTMERCH';
        eCclasse.PWINFO_AUTMERCHID          :  Result := 'PWINFO_AUTMERCHID';
        eCclasse.PWINFO_FINTYPE             :  Result := 'PWINFO_FINTYPE';
        eCclasse.PWINFO_INSTALLMENTS        :  Result := 'PWINFO_INSTALLMENTS';
        eCclasse.PWINFO_INSTALLMDATE        :  Result := 'PWINFO_INSTALLMDATE';
        eCclasse.PWINFO_RESULTMSG           :  Result := 'PWINFO_RESULTMSG';
        eCclasse.PWINFO_AUTLOCREF           :  Result := 'PWINFO_AUTLOCREF';
        eCclasse.PWINFO_AUTEXTREF           :  Result := 'PWINFO_AUTEXTREF';
        eCclasse.PWINFO_AUTHCODE            :  Result := 'PWINFO_AUTHCODE';
        eCclasse.PWINFO_AUTRESPCODE         :  Result := 'PWINFO_AUTRESPCODE';
        eCclasse.PWINFO_DISCOUNTAMT         :  Result := 'PWINFO_DISCOUNTAMT';
        eCclasse.PWINFO_CASHBACKAMT         :  Result := 'PWINFO_CASHBACKAMT';
        eCclasse.PWINFO_CARDNAME            :  Result := 'PWINFO_CARDNAME';
        eCclasse.PWINFO_BOARDINGTAX         :  Result := 'PWINFO_BOARDINGTAX';
        eCclasse.PWINFO_TIPAMOUNT           :  Result := 'PWINFO_TIPAMOUNT';
        eCclasse.PWINFO_TRNORIGDATE         :  Result := 'PWINFO_TRNORIGDATE';
        eCclasse.PWINFO_TRNORIGNSU          :  Result := 'PWINFO_TRNORIGNSU';
        eCclasse.PWINFO_TRNORIGAUTH         :  Result := 'PWINFO_TRNORIGAUTH';
        eCclasse.PWINFO_LANGUAGE            :  Result := 'PWINFO_LANGUAGE';
        eCclasse.PWINFO_TRNORIGTIME         :  Result := 'PWINFO_TRNORIGTIME';
        eCclasse.PWPTI_RESULT               :  Result := 'PWPTI_RESULT';
        eCclasse.PWINFO_CARDENTMODE         :  Result := 'PWINFO_CARDENTMODE';
        eCclasse.PWINFO_CARDPARCPAN         :  Result := 'PWINFO_CARDPARCPAN';
        eCclasse.PWINFO_CHOLDVERIF          :  Result := 'PWINFO_CHOLDVERIF';
        eCclasse.PWINFO_MERCHADDDATA1       :  Result := 'PWINFO_MERCHADDDATA1';
        eCclasse.PWINFO_MERCHADDDATA2       :  Result := 'PWINFO_MERCHADDDATA2';
        eCclasse.PWINFO_MERCHADDDATA3       :  Result := 'PWINFO_MERCHADDDATA3';
        eCclasse.PWINFO_MERCHADDDATA4       :  Result := 'PWINFO_MERCHADDDATA4';
        eCclasse.PWINFO_PNDAUTHSYST         :  Result := 'PWINFO_PNDAUTHSYST';
        eCclasse.PWINFO_PNDVIRTMERCH        :  Result := 'PWINFO_PNDVIRTMERCH';
        eCclasse.PWINFO_PNDAUTLOCREF        :  Result := 'PWINFO_PNDAUTLOCREF';
        eCclasse.PWINFO_PNDAUTEXTREF        :  Result := 'PWINFO_PNDAUTEXTREF';
        eCclasse.PWINFO_DUEAMNT             :  Result := 'PWINFO_DUEAMNT';
        eCclasse.PWINFO_READJUSTEDAMNT      :  Result := 'PWINFO_READJUSTEDAMNT';
        else
        begin
          Result := 'PWINFO_XXX';
        end;

      end;


      end;



end.
