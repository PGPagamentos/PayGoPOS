//************************************************************************************
  {
     unit:   POSPGWLib
     Classe: TPOSPGWLib

     Data de cria��o  :  02/07/2019
     Autor            :
     Descri��o        :
   }
//************************************************************************************
unit uPOSPGWLib;

interface


uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils, system.AnsiStrings,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Types, System.TypInfo, uPOSEnums;



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




  TPOSPGWLib = class
  private
  //private
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


    WszTerminalId :AnsiString;
    WszModel : AnsiString;
    WszMAC: AnsiString;
    WszSerNum: AnsiString;



    constructor Create;
    Destructor  Destroy; Override; // declara��o do metodo destrutor



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
                                           1: funcionalidade de troco/saque;
                                           2: funcionalidade de desconto;
                                           4: valor fixo, sempre incluir;
                                           8: impress�o das vias diferenciadas do comprovante para Cliente/Estabelecimento;
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
                      PWOPER_SALE            21h      Pagamento de mercadorias ou servi�os.
                      PWOPER_ADMIN           20h      Qualquer transa��o que n�o seja um pagamento (estorno,
                                                      pr�-autoriza��o, consulta, relat�rio, reimpress�o de recibo,etc).
                      PWOPER_SALEVOID        22h      Estorna uma transa��o de venda que foi previamente
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
  function PTI_EFT_GetInfo (pszTerminalId:AnsiString; iInfo:Int16;  uiBufLen:UInt16; var pszValue:AnsiString;
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

var


   sziRet : PSZ_GetiRet;

   szTerminalId:  PSZ_GetpszTerminalId;
   szModel: PSZ_GetpszModel;
   szMAC: PSZ_GetpszMAC;
   szSerNum: PSZ_GetpszSerNum;
   pszData: PSZ_GetpszData;





constructor TPOSPGWLib.Create;
begin


end;

destructor TPOSPGWLib.Destroy;
begin

  inherited;
end;






end.
