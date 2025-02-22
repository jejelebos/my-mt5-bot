//+------------------------------------------------------------------+
//|TheBestTradingBot.mq5                                             |
//|Copyright 2024, Jérémy Herrmann                                   |
//|https://modern-mood.com                                           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Jérémy Herrmann"
#property link      "https://modern-mood.com"
#property version   "1.00"
#property icon "TheBestTradingBot.ico"
#property description "This bot was coded by Jérémy"

// Required Libraries
#include <Arrays/ArrayObj.mqh>
#include <ChartObjects/ChartObjectsTxtControls.mqh>
#include <ChartObjects/ChartObjectsShapes.mqh>
#include <Trade/Trade.mqh>
#include <Arrays/ArrayString.mqh>
#include <Indicators/Trend.mqh>
#include <Indicators/Oscillators.mqh>

// Signal Type Enumeration
enum ENUM_SIGNAL_TYPE
  {
   SIGNAL_NONE,    // No Signal
   SIGNAL_BUY,     // Buy Signal
   SIGNAL_SELL     // Sell Signal
  };

// Trading Mode Enumeration
enum ENUM_TRADING_MODE
  {
   MODE_AUTOMATIC,   // Fully Automatic
   MODE_MANUAL      // Manual Confirmation Required
  };

// Alert Type Enumeration
enum ENUM_ALERT_TYPE
  {
   ALERT_NONE,       // No Alert
   ALERT_POPUP,      // Popup Alert
   ALERT_SOUND,      // Sound Alert
   ALERT_EMAIL,      // Email Alert
   ALERT_PUSH        // Push Notification
  };

int magicNb;
string magicFile = "TheBestTradingBot-magic_numbers.csv";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GenerateUniqueMagic()
  {
   int accountID = (int)AccountInfoInteger(ACCOUNT_LOGIN);
   long chartID = ChartID();
   datetime currentTime = TimeLocal();
   int randomPart = MathRand();

// Combine les valeurs pour générer un Magic Number initial
   long combinedValue = accountID + chartID + (long)currentTime + randomPart;

// Assure que le Magic Number est positif et dans la plage
   int magic = NormalizeMagic(MathAbs(combinedValue));

// Vérifie que le Magic Number est unique
   while(!IsMagicUnique(magic))
     {
      randomPart = MathRand(); // Re-génère une partie aléatoire
      combinedValue = accountID + chartID + (long)currentTime + randomPart;
      magic = NormalizeMagic(MathAbs(combinedValue));
     }

// Sauvegarde le Magic Number
   SaveMagicToFile(magic);

   return magic;
  }

// Normalise le Magic Number pour rester entre 0 et 999999999
int NormalizeMagic(long value)
  {
   return (int)(value % 1000000000); // Toujours positif grâce à MathAbs
  }

// Vérifie si le Magic Number existe déjà dans le fichier
bool IsMagicUnique(int magic)
  {
   ResetLastError();

// Ouvre le fichier en lecture
   int handle = FileOpen(magicFile, FILE_CSV | FILE_READ | FILE_COMMON);
   if(handle == INVALID_HANDLE)
      return true; // Si le fichier n'existe pas, le Magic Number est unique

   bool isUnique = true;
   while(!FileIsEnding(handle))
     {
      int savedMagic = (int)StringToInteger(FileReadString(handle));
      if(savedMagic == magic)
        {
         isUnique = false;
         break;
        }
     }
   FileClose(handle);
   return isUnique;
  }

// Sauvegarde le Magic Number dans le fichier
void SaveMagicToFile(int magic)
  {
   ResetLastError();

// Ouvre le fichier en écriture (append)
   int handle = FileOpen(magicFile, FILE_CSV | FILE_WRITE | FILE_COMMON | FILE_READ);
   if(handle == INVALID_HANDLE)
     {
      Print("Error opening file: ", GetLastError());
      return;
     }

   FileSeek(handle, 0, SEEK_END);
   FileWrite(handle, IntegerToString(magic));
   FileClose(handle);
  }

// Advanced Signal Structure
struct AdvancedSignal
  {
   ENUM_SIGNAL_TYPE  type;
   double            strength;
   double            confidence;
   double            price;
   datetime          time;
   string            description;
   bool              confirmed;
   double            riskRewardRatio;
   int               timeframe;

   // Additional signal metrics
   double            trendAlignment;
   double            volatilityScore;
   double            momentumScore;
   double            correlationScore;

   void              Reset()
     {
      type = SIGNAL_NONE;
      strength = 0;
      confidence = 0;
      price = 0;
      time = 0;
      description = "";
      confirmed = false;
      riskRewardRatio = 0;
      timeframe = PERIOD_CURRENT;
      trendAlignment = 0;
      volatilityScore = 0;
      momentumScore = 0;
      correlationScore = 0;
     }

   double            GetOverallScore()
     {
      return (strength + confidence + trendAlignment +
              volatilityScore + momentumScore + correlationScore) / 6;
     }
  };

// Enhanced Trading Statistics
struct EnhancedTradingStats
  {
   // Basic stats
   int               totalTrades;
   int               winningTrades;
   int               losingTrades;
   double            totalProfit;
   double            totalLoss;
   double            largestWin;
   double            largestLoss;
   double            winRate;
   double            profitFactor;

   // Advanced stats
   int               consecutiveWins;
   int               consecutiveLosses;
   int               maxConsecutiveWins;
   int               maxConsecutiveLosses;
   double            averageWinDuration;
   double            averageLossDuration;
   double            averageRRR;
   double            sharpeRatio;

   // Signal performance tracking
   int               signalSuccessCount[];
   int               signalFailureCount[];
   double            signalAccuracy[];

   void              Calculate()
     {
      winRate = totalTrades > 0 ? (double)winningTrades/totalTrades * 100 : 0;
      profitFactor = totalLoss != 0 ? MathAbs(totalProfit/totalLoss) : 0;

      // Calculate signal accuracy
      for(int i = 0; i < ArraySize(signalSuccessCount); i++)
        {
         int totalSignals = signalSuccessCount[i] + signalFailureCount[i];
         signalAccuracy[i] = totalSignals > 0 ?
                             (double)signalSuccessCount[i]/totalSignals * 100 : 0;
        }
     }

   void              Reset()
     {
      totalTrades = 0;
      winningTrades = 0;
      losingTrades = 0;
      totalProfit = 0;
      totalLoss = 0;
      largestWin = 0;
      largestLoss = 0;
      winRate = 0;
      profitFactor = 0;
      consecutiveWins = 0;
      consecutiveLosses = 0;
      maxConsecutiveWins = 0;
      maxConsecutiveLosses = 0;
      averageWinDuration = 0;
      averageLossDuration = 0;
      averageRRR = 0;
      sharpeRatio = 0;

      ArrayResize(signalSuccessCount, 3);
      ArrayResize(signalFailureCount, 3);
      ArrayResize(signalAccuracy, 3);
      ArrayInitialize(signalSuccessCount, 0);
      ArrayInitialize(signalFailureCount, 0);
      ArrayInitialize(signalAccuracy, 0);
     }
  };

// Market Analysis Structure
struct MarketAnalysis
  {
   double            trendStrength;
   double            volatility;
   double            momentum;
   double            support;
   double            resistance;
   double            rsi;
   double            macd;
   double            correlation;
   string            marketCondition;

   void              Reset()
     {
      trendStrength = 0;
      volatility = 0;
      momentum = 0;
      support = 0;
      resistance = 0;
      rsi = 0;
      macd = 0;
      correlation = 0;
      marketCondition = "";
     }
  };

// Risk Management Structure
struct RiskManagement
  {
   double            maxRiskPerTrade;
   double            maxDailyRisk;
   double            maxDrawdown;
   double            currentDailyRisk;
   double            currentDrawdown;
   double            accountBalance;
   double            equity;
   double            margin;
   double            freeMargin;

   void              Update()
     {
      accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      equity = AccountInfoDouble(ACCOUNT_EQUITY);
      margin = AccountInfoDouble(ACCOUNT_MARGIN);
      freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      currentDrawdown = (accountBalance - equity) / accountBalance * 100;
     }

   bool              CheckRiskLevels()
     {
      return (currentDailyRisk <= maxDailyRisk &&
              currentDrawdown <= maxDrawdown &&
              freeMargin > margin * 2);
     }
  };

// Global Variables
EnhancedTradingStats enhancedStats;
AdvancedSignal currentSignal;
MarketAnalysis marketAnalysis;
RiskManagement riskManager;
ENUM_TRADING_MODE tradingMode = MODE_AUTOMATIC;
ENUM_ALERT_TYPE alertType = ALERT_POPUP;
bool darkMode = false;

int rsiHandle;
int macdHandle;
int atrHandle;
int ma20Handle;
int ma50Handle;

int tradesToday = 0;
datetime lastTradeReset = 0;

static int lastPositionsCount = 0;

// Input Parameters

// === Trading Mode Settings ===
input group "=== Trading Mode Settings ==="
input ENUM_TRADING_MODE TradingMode = MODE_AUTOMATIC;    // Trading Mode
input ENUM_ALERT_TYPE AlertType = ALERT_POPUP;          // Alert Type
input bool EnableDarkMode = true;                      // Enable Dark Mode
input bool EnableCorrelationAnalysis = true;            // Enable Correlation Analysis
input bool EnableMarketSentiment = true;                // Enable Market Sentiment

// === Risk Management Settings ===
input group "=== Risk Management ==="
input double MaxRiskPerTrade = 2.0;                     // Max Risk Per Trade (%)
input double MaxLots = 5;                                  // Max Lots
input bool EnableReducePositionSize = true;             // Enable Reduce Position Size
input double ReducePositionSize = 70;                  // Reduce Position size if too high (%)
input double MaxDailyRisk = 6.0;                        // Max Daily Risk (%)
input double MaxDrawdown = 20.0;                        // Max Drawdown (%)
input bool UseBreakEven = true;                         // Use Break Even
input int BreakEvenPoints = 20;                         // Break Even Points
input bool UseTrailingStop = true;                      // Use Trailing Stop
input int TrailingPoints = 50;                          // Trailing Stop Points
input double AtrMultiplierSL = 5;                       // ATR Multiplier for SL
input double AtrMultiplierTP = 5;                       // ATR Multiplier for TP

// === Signal Settings ===
input group "=== Signal Settings ==="
input double MinSignalStrength = 70;                    // Minimum Signal Strength
input double MinSignalConfidence = 80;                  // Minimum Signal Confidence
input bool RequireMultiTimeframeConfirmation = true;    // Require Multi-Timeframe Confirmation
input int InpMultiTimeFrameConfirmations = 2;           // Multi-Timeframe Confirmation
input bool UseVolatilityFilter = true;                  // Use Volatility Filter
input double InpvolatilityFactor = 1.5;                 // Volatility Factor
input ulong MaxSpreadPoints = 10;                       // Maximum Spread in Points
input ulong Slippage = 5;                               // Maximum Slippage
input int MaxOpenPositions = 5;                         // Maximum Open Positions
input int MaxTradePerDay = 10;                          // Maximum Trade Per Day

// === Visual Settings ===
input group "=== Visual Settings ==="
input color BuySignalColor = clrLime;                   // Arrow Buy Signal Color
input color SellSignalColor = clrRed;                   // Arrow Sell Signal Color
input int SignalArrowSize = 3;                          // Signal Arrow Size
input bool ShowConfidenceLevel = true;                  // Show Confidence Level
input bool EnableSignalAnimation = true;                // Enable Signal Animation
input bool ShowTradeHistory = true;                     // Show Trade History

// === Alert Settings ===
input group "=== Alert Settings ==="
input bool EnableSoundAlerts = true;                    // Enable Sound Alerts
input bool EnableEmailAlerts = false;                   // Enable Email Alerts
input bool EnablePushNotifications = false;             // Enable Push Notifications
input string SoundFileName = "alert.wav";               // Sound File Name

// === Add Settings ===
input group "=== Add Settings ==="
input bool EnableTradingInfoBoxes = true;               // Enable Trading Info Boxes
input bool EnableStatisticsBoxes = true;                // Enable Statistics Boxes
input bool EnableCurrentSignalBoxes = true;             // Enable Current Signal Boxes
input bool EnableServerInfoBoxes = true;                // Enable Server Info Boxes
input bool CandleOnTop = false;                         // Candles Above The Boxes


//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(MaxRiskPerTrade <= 0 || MaxRiskPerTrade > 100)
     {
      Print("MaxRiskPerTrade invalid");
      return INIT_FAILED;
     }

   if(MaxDailyRisk <= 0 || MaxDailyRisk > 100)
     {
      Print("MaxDailyRisk invalid");
      return INIT_FAILED ;
     }

   if(MaxDrawdown <= 0 || MaxDrawdown > 100)
     {
      Print("MaxDrawdown invalid");
      return INIT_FAILED;
     }

   if(!SymbolInfoDouble(_Symbol, SYMBOL_BID) ||
      !SymbolInfoDouble(_Symbol, SYMBOL_ASK))
     {
      Print("Symbol price retrieval error");
      return INIT_FAILED;
     }

// Initialize components
   magicNb = GenerateUniqueMagic();
   enhancedStats.Reset();
   currentSignal.Reset();
   marketAnalysis.Reset();
   riskManager.Update();

// Configure trading mode and interface
   tradingMode = TradingMode;
   alertType = AlertType;
   darkMode = EnableDarkMode;


// Configure chart appearance
   if(darkMode)
     {
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);
      ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrWhite);
      ChartSetInteger(0, CHART_SHOW_GRID, false);
      ChartSetInteger(0, CHART_AUTOSCROLL, true);
      ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY, false);
      ChartSetInteger(0, CHART_COLOR_CHART_UP, clrGreen);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrRed);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrGreen);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrRed);
      ChartSetInteger(0, CHART_SHOW_ONE_CLICK, false);
      if(ShowTradeHistory)
        {
         ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY, true);
        }
      else
        {
         ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY, false);
        }
     }
   else
     {
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite);
      ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack);
      ChartSetInteger(0, CHART_SHOW_GRID, false);
      ChartSetInteger(0, CHART_AUTOSCROLL, true);
      ChartSetInteger(0, CHART_SHOW_ONE_CLICK, false);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrGreen);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrRed);
      ChartSetInteger(0, CHART_COLOR_CHART_UP, clrGreen);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrRed);
      if(ShowTradeHistory)
        {
         ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY, true);
        }
      else
        {
         ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY, false);
        }
     }

// Initialiser les handles d'indicateurs
   rsiHandle = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   macdHandle = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
   atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
   ma20Handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
   ma50Handle = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);

// Vérifier tous les handles
   if(rsiHandle == INVALID_HANDLE)
     {
      Print("Error creating RSI handle");
      return INIT_FAILED;
     }
   if(macdHandle == INVALID_HANDLE)
     {
      Print("Error creating MACD handle");
      return INIT_FAILED;
     }
   if(atrHandle == INVALID_HANDLE)
     {
      Print("Error creating ATR handle");
      return INIT_FAILED;
     }
   if(ma20Handle == INVALID_HANDLE)
     {
      Print("Error creating handle MA20");
      return INIT_FAILED;
     }
   if(ma50Handle == INVALID_HANDLE)
     {
      Print("Error creating handle MA50");
      return INIT_FAILED;
     }

// Create interface panels
   if(EnableTradingInfoBoxes)
     {
      CreateMainPanel();
     }
   if(EnableStatisticsBoxes)
     {
      CreateStatisticsPanel();
     }
   if(EnableCurrentSignalBoxes)
     {
      CreateSignalPanel();
     }
   if(EnableServerInfoBoxes)
     {
      CreateServerPanel();
     }
//CreateExpertPanel();


   if(magicNb <= 0)
     {
      Print("Error generating Magic Number");
      return INIT_FAILED;
     }
   else
     {
      Print("Magic Number: " + magicNb);
     }

   bool initSuccess = true;


   if(Symbol() == "")
     {
      initSuccess = false;
     }

   if(initSuccess)
     {
      Print("The Bot has been successfully loaded, and now the profits will begin.");
      return INIT_SUCCEEDED;
     }
   else
     {
      string errorMessage;
      int errorCode = GetLastError();

      switch(errorCode)
        {
         case 0:
            errorMessage = "No error detected, but initialization failed.";
            break;
         case 1:
            errorMessage = "Critical error in the platform. Restart the application.";
            break;
         case 2:
            errorMessage = "Invalid input parameter.";
            break;
         case 3:
            errorMessage = "Invalid function call sequence.";
            break;
         case 4:
            errorMessage = "Insufficient memory.";
            break;
         case 5:
            errorMessage = "Request timed out. Check your internet connection.";
            break;
         case 6:
            errorMessage = "Array out of range.";
            break;
         case 8:
            errorMessage = "Unknown runtime error.";
            break;
         case 128:
            errorMessage = "Invalid trade volume.";
            break;
         case 129:
            errorMessage = "Invalid trade price.";
            break;
         case 130:
            errorMessage = "Invalid stops. Stop loss or take profit is incorrect.";
            break;
         case 131:
            errorMessage = "Invalid trade volume. Lot size is not permitted.";
            break;
         case 132:
            errorMessage = "Market is closed. Trading not allowed.";
            break;
         case 133:
            errorMessage = "Trade is disabled.";
            break;
         case 134:
            errorMessage = "Not enough memory available to load the bot.";
            break;
         case 135:
            errorMessage = "Invalid trade parameters.";
            break;
         case 136:
            errorMessage = "Server is busy. Try again later.";
            break;
         case 137:
            errorMessage = "Order is locked by the trading server.";
            break;
         case 138:
            errorMessage = "Requote. Market price has changed.";
            break;
         case 139:
            errorMessage = "Order was not accepted by the server.";
            break;
         case 140:
            errorMessage = "Trade request was rejected by the server.";
            break;
         case 141:
            errorMessage = "Trading is prohibited. Check platform settings.";
            break;
         case 145:
            errorMessage = "Trade context is busy. Wait for the previous operation.";
            break;
         case 146:
            errorMessage = "Automated trading is not allowed. Please enable it in the platform.";
            break;
         case 147:
            errorMessage = "Invalid request. Check the parameters.";
            break;
         case 148:
            errorMessage = "Trade is not allowed. Check account settings.";
            break;
         case 149:
            errorMessage = "Invalid expiration time.";
            break;
         case 4000:
            errorMessage = "Server is down or unreachable.";
            break;
         case 4100:
            errorMessage = "No connection. Verify your internet.";
            break;
         case 4101:
            errorMessage = "Invalid account number.";
            break;
         case 4102:
            errorMessage = "Account has insufficient funds.";
            break;
         case 4103:
            errorMessage = "Invalid account credentials.";
            break;
         case 4104:
            errorMessage = "Trade request was rejected by the server.";
            break;
         case 4105:
            errorMessage = "Account is disabled.";
            break;
         case 4106:
            errorMessage = "No connection to the trading server.";
            break;
         case 4107:
            errorMessage = "Order was canceled.";
            break;
         case 4108:
            errorMessage = "Invalid stop loss or take profit value.";
            break;
         case 4109:
            errorMessage = "Trade is not allowed. Check account settings.";
            break;
         case 4110:
            errorMessage = "Order modify failed.";
            break;
         case 4111:
            errorMessage = "Order delete failed.";
            break;
         case 4112:
            errorMessage = "Market is closed or trading is disabled.";
            break;
         case 4200:
            errorMessage = "Trade server is not responding.";
            break;
         case 4201:
            errorMessage = "Invalid request format.";
            break;
         case 4202:
            errorMessage = "Authorization error. Verify your credentials.";
            break;
         case 4203:
            errorMessage = "Trade operation is restricted by the server.";
            break;
         default:
            errorMessage = "Unknown error occurred. Error code: " + IntegerToString(errorCode);
            break;
        }

      Print("The Bot has not been successfully loaded. Reason: ", errorMessage);
      return INIT_FAILED;
     }
  }

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   ChartSetInteger(0, CHART_AUTOSCROLL, true);

   if(EnableTradingInfoBoxes)
     {
      CreateMainPanel();
     }
   if(EnableStatisticsBoxes)
     {
      CreateStatisticsPanel();
     }
   if(EnableCurrentSignalBoxes)
     {
      CreateSignalPanel();
     }
   if(EnableServerInfoBoxes)
     {
      CreateServerPanel();
     }

   ApplyTrailingStop();

   // Update market analysis
   UpdateMarketAnalysis();

   // Generate and process signals
   GenerateSignals();

   // Update risk management
   riskManager.Update();

   // Check position sl and tp
   // CheckAndSetSLTP();

   // Handle trading based on mode
   switch(tradingMode)
     {
      case MODE_AUTOMATIC:
         HandleAutomaticTrading();
         break;
      case MODE_MANUAL:
         HandleManualTrading();
         break;
     }

   // Vérifier si une position a été fermée et réinitialiser SIGNAL_NONE
   int currentPositionsCount = PositionsTotal();
   if (currentPositionsCount < lastPositionsCount) {
      for (int i = 0; i < lastPositionsCount; i++) {
         ulong ticket = PositionGetTicket(i);
         bool isPositionClosed = !PositionSelectByTicket(ticket);
         
         if (isPositionClosed) {
            SetSignal(SIGNAL_NONE);
            break;
         }
      }
   }
   lastPositionsCount = currentPositionsCount;
}

void SetSignal(int signal)
{
   string ENUM_SIGNAL_TYPE = signal;
   Print("Signal set to ", signal);
}

//+------------------------------------------------------------------+
//| Update market analysis                                            |
//+------------------------------------------------------------------+
void UpdateMarketAnalysis()
  {
   double rsiBuffer[], macdBuffer[], signalBuffer[];

   ArraySetAsSeries(rsiBuffer, true);
   ArraySetAsSeries(macdBuffer, true);
   ArraySetAsSeries(signalBuffer, true);

// Copier les données des indicateurs
   if(CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) > 0)
     {
      marketAnalysis.rsi = rsiBuffer[0];
     }

   if(CopyBuffer(macdHandle, 0, 0, 1, macdBuffer) > 0 &&
      CopyBuffer(macdHandle, 1, 0, 1, signalBuffer) > 0)
     {
      marketAnalysis.macd = macdBuffer[0];
     }

// Calculer les autres métriques
   marketAnalysis.trendStrength = CalculateTrendStrength();
   marketAnalysis.volatility = CalculateVolatility();
   marketAnalysis.momentum = CalculateMomentum();
   CalculateSupportResistanceLevel();

   if(EnableMarketSentiment)
     {
      UpdateMarketSentiment();
     }
  }

//+------------------------------------------------------------------+
//| Generate trading signals                                          |
//+------------------------------------------------------------------+
void GenerateSignals()
  {
   double trendSignal = CalculateTrendSignal(PERIOD_CURRENT);
   double momentumSignal = CalculateMomentumSignal();
   double volumeSignal = CalculateVolumeSignal();

// Normalize signals between -1 and 1
   double signalStrength = (trendSignal + momentumSignal + volumeSignal);
   double confidence = MathAbs(signalStrength) * 100;

   if(confidence >= MinSignalConfidence)
     {
      currentSignal.type = signalStrength > 0 ? SIGNAL_BUY : SIGNAL_SELL;
      currentSignal.strength = MathAbs(signalStrength);
      currentSignal.confidence = confidence;
      currentSignal.price = SymbolInfoDouble(_Symbol, currentSignal.type == SIGNAL_BUY ? SYMBOL_ASK : SYMBOL_BID);
      currentSignal.time = TimeCurrent();
     }
   else
     {
      currentSignal.type = SIGNAL_NONE;
     }
  }

//+------------------------------------------------------------------+
//| Create signal visualization                                       |
//+------------------------------------------------------------------+
void CreateSignalVisualization()
  {
   if(!ShowConfidenceLevel)
      return;

   string signalName = "Signal_" + TimeToString(currentSignal.time);
   color signalColor = currentSignal.type == SIGNAL_BUY ? BuySignalColor : SellSignalColor;

// Create arrow
   CreateSignalArrow(signalName, currentSignal.price, signalColor);

// Create confidence label
   if(ShowConfidenceLevel)
     {
      CreateConfidenceLabel(signalName, currentSignal.confidence);
     }

// Animate signal if enabled
   if(EnableSignalAnimation)
     {
      AnimateSignal(signalName);
     }
  }

//+------------------------------------------------------------------+
//| Create signal arrow                                               |
//+------------------------------------------------------------------+
void CreateSignalArrow(string name, double price, color arrowColor)
  {
   ENUM_OBJECT arrowType = currentSignal.type == SIGNAL_BUY ?
                           OBJ_ARROW_BUY : OBJ_ARROW_SELL;

   if(ObjectCreate(0, name, arrowType, 0, currentSignal.time, price))
     {
      ObjectSetInteger(0, name, OBJPROP_COLOR, arrowColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, SignalArrowSize);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
     }
  }

//+------------------------------------------------------------------+
//| Create confidence label                                           |
//+------------------------------------------------------------------+
void CreateConfidenceLabel(string signalName, double confidence)
  {
   string labelName = signalName + "_Label";
   string labelText = DoubleToString(confidence, 1) + "%";

   if(ObjectCreate(0, labelName, OBJ_TEXT, 0, currentSignal.time, currentSignal.price))
     {
      ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, currentSignal.type == SIGNAL_BUY ?
                       BuySignalColor : SellSignalColor);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
     }
  }

//+------------------------------------------------------------------+
//| Animate signal                                                    |
//+------------------------------------------------------------------+
void AnimateSignal(string name)
  {
   for(int i = 0; i < 5; i++)
     {
      ObjectSetInteger(0, name, OBJPROP_WIDTH, SignalArrowSize + i);
      Sleep(100);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, SignalArrowSize);
      Sleep(100);
     }
  }

//+------------------------------------------------------------------+
//| Send signal alerts                                                |
//+------------------------------------------------------------------+
void SendSignalAlerts()
  {
   string alertMessage = StringFormat("%s Signal\nStrength: %.1f%%\n   Confidence: %.1f%%",
                                      EnumToString(currentSignal.type),
                                      currentSignal.strength,
                                      currentSignal.confidence);

// Send alerts based on settings
   if(EnableSoundAlerts)
     {
      PlaySound(SoundFileName);
     }

   if(EnableEmailAlerts)
     {
      SendMail("Trading Signal Alert", alertMessage);
     }

   if(EnablePushNotifications)
     {
      SendNotification(alertMessage);
     }

   switch(alertType)
     {
      case ALERT_POPUP:
         Alert(alertMessage);
         break;
      case ALERT_SOUND:
         PlaySound("alert.wav");
         break;
      case ALERT_EMAIL:
         SendMail("Trading Signal Alert", alertMessage);
         break;
      case ALERT_PUSH:
         SendNotification(alertMessage);
         break;
     }
  }

//+------------------------------------------------------------------+
//| Handle automatic trading                                          |
//+------------------------------------------------------------------+
void HandleAutomaticTrading() {
    if(currentSignal.type == SIGNAL_NONE) return;
    
    // Ajouter filtre de tendance
    if(!IsTrendFavorable()) return;
    
    // Vérifier la divergence prix/RSI
   // if(CheckPriceRSIDivergence()) return;

// Check trading conditions
   if(!CheckTradingConditions())
      return;

// Calculate position size
   double volume = CalculatePositionSize();

// Open position
   if(currentSignal.type == SIGNAL_BUY)
     {
      OpenBuyPosition(volume);
     }
   else
     {
      OpenSellPosition(volume);
     }
  }
  
//+------------------------------------------------------------------+
//| Is Trend Favorable                                               |
//+------------------------------------------------------------------+
bool IsTrendFavorable() {
    double ma200 = iMA(_Symbol,PERIOD_CURRENT,200,0,MODE_SMA,PRICE_CLOSE);
    double price = iClose(_Symbol,PERIOD_CURRENT,0);
    
    if(currentSignal.type == SIGNAL_BUY && price < ma200) return false;
    if(currentSignal.type == SIGNAL_SELL && price > ma200) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Handle manual trading                                             |
//+------------------------------------------------------------------+
void HandleManualTrading()
  {
   if(currentSignal.type == SIGNAL_NONE)
      return;

   string message = StringFormat("New %s Signal\nConfidence: %.1f%%\nExecute trade?",
                                 EnumToString(currentSignal.type),
                                 currentSignal.confidence);

   if(MessageBox(message, "Trade Confirmation", MB_YESNO) == IDYES)
     {
      double volume = CalculatePositionSize();

      if(currentSignal.type == SIGNAL_BUY)
        {
         OpenBuyPosition(volume);
        }
      else
        {
         OpenSellPosition(volume);
        }
     }
  }

//+------------------------------------------------------------------+
//| Calculate position size based on risk                             |
//+------------------------------------------------------------------+
double CalculatePositionSize()
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double riskAmount = equity * MaxRiskPerTrade / 100;
    double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double stopLoss = CalculateStopLoss();
    double stopLossPoints = stopLoss / pointValue;

    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = MathMin(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX), MaxLots);

    double positionSize = NormalizeDouble(riskAmount / (stopLossPoints * pointValue), 2);

    if (EnableReducePositionSize) {
        while (positionSize > maxLot) {
            riskAmount /= ReducePositionSize;
            positionSize = NormalizeDouble(riskAmount / (stopLossPoints * pointValue), 2);
            if (riskAmount <= 0) {
                Print("Erreur : Montant de risque trop faible après réduction.");
                break;
            }
        }
    }

    positionSize = MathMax(minLot, MathMin(maxLot, positionSize));

    return positionSize;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMaxPositionSize()
  {
   double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double maxRiskAmount = accountEquity * (MaxRiskPerTrade / 100);
   double stopLossPoints = CalculateStopLoss() / _Point;
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   double maxPositionSize = maxRiskAmount / (stopLossPoints * tickValue);
   maxPositionSize = NormalizeDouble(maxPositionSize, 2);

// Ajout d'une réduction progressive basée sur le drawdown
   double currentDrawdown = (1 - AccountInfoDouble(ACCOUNT_EQUITY) / AccountInfoDouble(ACCOUNT_BALANCE)) * 100;
   if(currentDrawdown > 5)
     {
      maxPositionSize *= (1 - (currentDrawdown - 5) / 15); // Réduction progressive
     }

   return maxPositionSize;
  }

//+------------------------------------------------------------------+
//| Calculate stop loss level                                         |
//+------------------------------------------------------------------+
double CalculateStopLoss()
  {
   if(currentSignal.type == SIGNAL_NONE)
      return 0;

   double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
   double stopLossPoints = atr * AtrMultiplierSL;

// Convert to price
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double stopLossPrice = stopLossPoints * pointValue;

// Ensure minimum stop loss distance
   double minStop = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * pointValue;
   stopLossPrice = MathMax(stopLossPrice, minStop);

   return stopLossPrice;
  }

//+------------------------------------------------------------------+
//| Calculate take profit                                            |
//+------------------------------------------------------------------+
double CalculateTakeProfit()
  {
   if(currentSignal.type == SIGNAL_NONE)
      return 0;

   double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
   double takeProfitPoints = atr * AtrMultiplierTP;

// Convert to price
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double takeProfitPrice = takeProfitPoints * pointValue;

// Ensure minimum stop loss distance
   double minStop = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * pointValue;
   takeProfitPrice = MathMax(takeProfitPrice, minStop);

   return takeProfitPrice;
  }

//+------------------------------------------------------------------+
//| Calculate support and resistance level                           |
//+------------------------------------------------------------------+
double CalculateSupportResistanceLevel()
  {
   double lowPrices[], highPrices[];
   ArraySetAsSeries(lowPrices, true);
   ArraySetAsSeries(highPrices, true);

   CopyLow(_Symbol, PERIOD_CURRENT, 0, 20, lowPrices);
   CopyHigh(_Symbol, PERIOD_CURRENT, 0, 20, highPrices);

   double supportLevel = lowPrices[ArrayMinimum(lowPrices, 0, 20)];
   double resistanceLevel = highPrices[ArrayMaximum(highPrices, 0, 20)];

   if(currentSignal.type == SIGNAL_BUY && supportLevel > 0)
     {
      return supportLevel;
     }
   if(currentSignal.type == SIGNAL_SELL && resistanceLevel > 0)
     {
      return resistanceLevel;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetTradeCounterIfNeeded()
  {
   datetime currentTime = TimeCurrent();
   MqlDateTime currentTimeStruct, lastResetStruct;

   TimeToStruct(currentTime, currentTimeStruct);
   TimeToStruct(lastTradeReset, lastResetStruct);

   if(currentTimeStruct.day != lastResetStruct.day ||
      currentTimeStruct.mon != lastResetStruct.mon ||
      currentTimeStruct.year != lastResetStruct.year)
     {
      tradesToday = 0;
      lastTradeReset = currentTime;
     }
  }

//+------------------------------------------------------------------+
//| Open buy position                                                 |
//+------------------------------------------------------------------+
void OpenBuyPosition(double volume)
  {
   ResetTradeCounterIfNeeded();

   if(tradesToday >= MaxTradePerDay)
     {
      Print("Max Trades Per Day Reached");
      return;
     }
   if(PositionsTotal() >= MaxOpenPositions)
     {
      Print("Max Open Positions Reached");
      return;
     }
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = price - CalculateStopLoss();
   double tp = price + CalculateTakeProfit();

   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = volume;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = Slippage;
   request.magic = magicNb;
   request.comment = "Buy Order";
   request.type = ORDER_TYPE_BUY;
   request.type_time = ORDER_TIME_GTC;

   if(OrderSend(request, result) && result.retcode == 10009)
     {
      UpdateTradeStats(true);
      tradesToday++;
     }
  }

//+------------------------------------------------------------------+
//| Open sell position                                                |
//+------------------------------------------------------------------+
void OpenSellPosition(double volume)
  {
   ResetTradeCounterIfNeeded();

   if(tradesToday >= MaxTradePerDay)
     {
      Print("Max Trades Per Day Reached");
      return;
     }
   if(PositionsTotal() >= MaxOpenPositions)
     {
      Print("Max Open Positions Reached");
      return;
     }
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = price + CalculateStopLoss();
   double tp = price - CalculateTakeProfit();

   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = volume;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = Slippage;
   request.magic = magicNb;
   request.comment = "Sell Order";
   request.type = ORDER_TYPE_SELL;
   request.type_time = ORDER_TIME_GTC;

   if(OrderSend(request, result) && result.retcode == 10009)
     {
      UpdateTradeStats(true);
      tradesToday++;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyTrailingStop()
  {
   if(!UseTrailingStop || TrailingPoints <= 0)
      return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                            ? SymbolInfoDouble(symbol, SYMBOL_BID)
                            : SymbolInfoDouble(symbol, SYMBOL_ASK);

      double currentSL = PositionGetDouble(POSITION_SL);
      double newSL;

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         newSL = currentPrice - TrailingPoints * _Point;
         if(newSL > openPrice && (currentSL == 0 || newSL > currentSL))
           {
            UpdateStopLoss(ticket, newSL, POSITION_TYPE_BUY);
           }
        }
      else
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            newSL = currentPrice + TrailingPoints * _Point;
            if(newSL < openPrice && (currentSL == 0 || newSL < currentSL))
              {
               UpdateStopLoss(ticket, newSL, POSITION_TYPE_SELL);
              }
           }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateStopLoss(ulong ticket, double newSL, int positionType)
  {
   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_SLTP;
   request.symbol = PositionGetString(POSITION_SYMBOL);
   request.sl = newSL;
   request.tp = PositionGetDouble(POSITION_TP);
   request.position = ticket;

   if(!OrderSend(request, result))
     {
      Print("Failed to update SL for ticket ", ticket, ". Error: ", GetLastError());
     }
   else
      if(result.retcode != 10009)
        {
         Print("SL update failed for ticket ", ticket, ". Retcode: ", result.retcode);
        }
  }

//+------------------------------------------------------------------+
//| Check position TP and SL                                         |
//+------------------------------------------------------------------+
void CheckAndSetSLTP()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);

      if(PositionSelectByTicket(ticket))
        {
         double currentSL = PositionGetDouble(POSITION_SL);
         double currentTP = PositionGetDouble(POSITION_TP);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         double stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
         double sl, tp;

         if(positionType == POSITION_TYPE_BUY)
           {
            sl = MathMax(openPrice - _Point * CalculateStopLoss(), openPrice - stopLevel);
            tp = MathMax(openPrice + _Point * CalculateTakeProfit(), openPrice + stopLevel);
           }
         else
            if(positionType == POSITION_TYPE_SELL)
              {
               sl = MathMin(openPrice + _Point * CalculateStopLoss(), openPrice + stopLevel);
               tp = MathMin(openPrice - _Point * CalculateTakeProfit(), openPrice - stopLevel);
              }
            else
              {
               continue;
              }

         if((positionType == POSITION_TYPE_BUY && (sl >= openPrice || tp <= openPrice)) ||
            (positionType == POSITION_TYPE_SELL && (sl <= openPrice || tp >= openPrice)))
           {
            Print("Invalid SL/TP levels for the ticket ", ticket);
            continue;
           }

         if(currentSL == 0 || currentTP == 0)
           {
            MqlTradeRequest modifyRequest = {};
            MqlTradeResult modifyResult = {};

            modifyRequest.action = TRADE_ACTION_SLTP;
            modifyRequest.symbol = PositionGetString(POSITION_SYMBOL);
            modifyRequest.sl = currentSL == 0 ? sl : currentSL;
            modifyRequest.tp = currentTP == 0 ? tp : currentTP;
            modifyRequest.magic = PositionGetInteger(POSITION_MAGIC);

            if(!OrderSend(modifyRequest, modifyResult))
              {
               Print("SL/TP modification error for ticket ", ticket,
                     ": SL=", modifyRequest.sl, " TP=", modifyRequest.tp,
                     " Retcode=", modifyResult.retcode);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Update trade statistics                                           |
//+------------------------------------------------------------------+
void UpdateTradeStats(bool isWin)
  {
   enhancedStats.totalTrades++;

   if(isWin)
     {
      enhancedStats.winningTrades++;
      enhancedStats.consecutiveWins++;
      enhancedStats.consecutiveLosses = 0;

      enhancedStats.maxConsecutiveWins = MathMax(enhancedStats.maxConsecutiveWins,
                                         enhancedStats.consecutiveWins);
     }
   else
     {
      enhancedStats.losingTrades++;
      enhancedStats.consecutiveLosses++;
      enhancedStats.consecutiveWins = 0;
      enhancedStats.maxConsecutiveLosses = MathMax(enhancedStats.maxConsecutiveLosses,
                                           enhancedStats.consecutiveLosses);
     }

   enhancedStats.Calculate();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateMainPanel()
  {
   string name = "MainPanel";
   if(ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, 205);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, 230);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, darkMode ? clrWhite : clrBlack);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, darkMode ? clrBlack : clrWhite);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
      ObjectSetInteger(0, name, OBJPROP_COLOR, darkMode ? clrYellow : clrYellow);
      if(CandleOnTop)
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
        }
      else
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, false);
        }
     }

   int startY = 30; // Starting Y position
   int spacing = 35; // Spacing between lines
   color textColor = darkMode ? clrBlack : clrWhite;

   CreateLabel("MainPanelTitle", 20, startY, "  === TRADING INFO ===", textColor);
   startY += spacing;
   CreateLabel("MainPanelMode", 20, startY, "Mode: " + EnumToString(tradingMode), textColor);
   startY += spacing;
   CreateLabel("MainPanelBalance", 20, startY, "Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2), textColor);
   startY += spacing;
   CreateLabel("MainPanelEquity", 20, startY, "Equity: " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2), textColor);
   startY += spacing;
   CreateLabel("MainPanelDrawdown", 20, startY, "Drawdown: " + DoubleToString(riskManager.currentDrawdown, 2) + "%", textColor);
   startY += spacing;
   CreateLabel("MainSymbol", 20, startY, "Symbol: " + _Symbol, textColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateStatisticsPanel()
  {
   string name = "StatsPanel";
   if(ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 240);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, 220);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, 230);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, darkMode ? clrWhite : clrBlack);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, darkMode ? clrBlack : clrWhite);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
      ObjectSetInteger(0, name, OBJPROP_COLOR, darkMode ? clrYellow : clrYellow);
      if(CandleOnTop)
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
        }
      else
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, false);
        }
     }

   int startY = 30;
   int spacing = 35;
   color textColor = darkMode ? clrBlack : clrWhite;

   CreateLabel("StatsPanelTitle", 250, startY, "    === STATISTICS ===", textColor);
   startY += spacing;
   CreateLabel("StatsPanelTotalTrades", 250, startY, "Total Trades: " + IntegerToString(enhancedStats.totalTrades), textColor);
   startY += spacing;
   CreateLabel("StatsPanelWinRate", 250, startY, "Win Rate: " + DoubleToString(enhancedStats.winRate, 1) + "%", textColor);
   startY += spacing;
   CreateLabel("StatsPanelProfitFactor", 250, startY, "Profit Factor: " + DoubleToString(enhancedStats.profitFactor, 2), textColor);
   startY += spacing;
   CreateLabel("StatsPanelConsecutiveWins", 250, startY, "Consecutive Wins: " + IntegerToString(enhancedStats.consecutiveWins), textColor);
   startY += spacing;
   CreateLabel("StatsPanelConsecutiveLosses", 250, startY, "Consecutive Losses: " + IntegerToString(enhancedStats.consecutiveLosses), textColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateSignalPanel()
  {
   string name = "SignalPanel";
   if(ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 480);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, 220);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, 230);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, darkMode ? clrWhite : clrBlack);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, darkMode ? clrBlack : clrWhite);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
      ObjectSetInteger(0, name, OBJPROP_COLOR, darkMode ? clrYellow : clrYellow);
      if(CandleOnTop)
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
        }
      else
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, false);
        }
     }

   int startY = 30;
   int spacing = 35;
   color textColor = darkMode ? clrBlack : clrWhite;

   CreateLabel("SignalPanelTitle", 490, startY, "=== CURRENT SIGNAL ===", textColor);
   startY += spacing;
   CreateLabel("SignalPanelType", 490, startY, "Type: " + EnumToString(currentSignal.type), textColor);
   startY += spacing;
   CreateLabel("SignalPanelStrength", 490, startY, "Strength: " + DoubleToString(currentSignal.strength, 1) + "%", textColor);
   startY += spacing;
   CreateLabel("SignalPanelConfidence", 490, startY, "Confidence: " + DoubleToString(currentSignal.confidence, 1) + "%", textColor);
   startY += spacing;
   CreateLabel("SignalPanelRR", 490, startY, "RR Ratio: " + DoubleToString(currentSignal.riskRewardRatio, 2), textColor);
   startY += spacing;
   CreateLabel("SignalPanelVolatility", 490, startY, "Volatility: " + DoubleToString(CalculateVolatility(), 2), textColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateServerPanel()
  {
   string name = "ServerPanel";
   if(ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 720);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, 220);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, 230);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, darkMode ? clrWhite : clrBlack);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, darkMode ? clrBlack : clrWhite);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
      ObjectSetInteger(0, name, OBJPROP_COLOR, darkMode ? clrBlack : clrWhite);
      if(CandleOnTop)
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
        }
      else
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, false);
        }
     }

   int startY = 30;
   int spacing = 35;
   color textColor = darkMode ? clrBlack : clrWhite;

   CreateLabel("ServerPanelTitle", 730, startY, "  === SERVER INFO ===", textColor);
   startY += spacing;
   CreateLabel("ServerPanelName", 730, startY, "Name: " + AccountInfoString(ACCOUNT_NAME), textColor);
   startY += spacing;
   CreateLabel("ServerPanelLogin", 730, startY, "Login: " + AccountInfoInteger(ACCOUNT_LOGIN), textColor);
   startY += spacing;
   CreateLabel("ServerPanelServer", 730, startY, "Server: " + AccountInfoString(ACCOUNT_SERVER), textColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateExpertPanel()
  {
   string name = "ExpertPanel";
   if(ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 1270);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, 130);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, 10);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, darkMode ? clrBlack : clrWhite);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, darkMode ? clrWhite : clrBlack);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
      ObjectSetInteger(0, name, OBJPROP_COLOR, darkMode ? clrWhite : clrBlack);
      if(CandleOnTop)
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
        }
      else
        {
         ObjectSetInteger(0, name, OBJPROP_BACK, false);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string labelName, int xDistance, int yDistance, string text, color textColor)
  {
   if(ObjectFind(0, labelName) == -1)
     {
      ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, xDistance);
      ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, yDistance);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, textColor);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 9);
     }
   ObjectSetString(0, labelName, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
//| Calculate trend strength                                          |
//+------------------------------------------------------------------+
double CalculateTrendStrength()
  {
   double ma20Buffer[], ma50Buffer[], ma200Buffer[];

   ArraySetAsSeries(ma20Buffer, true);
   ArraySetAsSeries(ma50Buffer, true);
   ArraySetAsSeries(ma200Buffer, true);

   if(CopyBuffer(ma20Handle, 0, 0, 2, ma20Buffer) <= 0 ||
      CopyBuffer(ma50Handle, 0, 0, 2, ma50Buffer) <= 0)
     {
      return 0;
     }

   double strength = 0;

// Vérifier l'alignement des MA
   if(ma20Buffer[0] > ma50Buffer[0])
      strength += 50;
   if(ma20Buffer[0] < ma50Buffer[0])
      strength -= 50;

// Vérifier les pentes
   double ma20Slope = ma20Buffer[0] - ma20Buffer[1];
   double ma50Slope = ma50Buffer[0] - ma50Buffer[1];

   if(ma20Slope > 0)
      strength += 25;
   if(ma20Slope < 0)
      strength -= 25;
   if(ma50Slope > 0)
      strength += 25;
   if(ma50Slope < 0)
      strength -= 25;

   return MathAbs(strength);
  }

//+------------------------------------------------------------------+
//| Calculate volatility                                              |
//+------------------------------------------------------------------+
double CalculateVolatility()
  {
   double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double highPrice = iHigh(_Symbol, PERIOD_CURRENT, 1);
   double lowPrice = iLow(_Symbol, PERIOD_CURRENT, 1);
   double averagePrice = (askPrice + bidPrice + highPrice + lowPrice) / 4;

   if(averagePrice <= 0 || atr <= 0)
      return 0;

   double priceRange = (highPrice - lowPrice) / averagePrice * 100;
   double volatility = (atr / averagePrice + priceRange) / 2 * 100;

   return NormalizeDouble(volatility, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsVolatilityAcceptable()
  {
   double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
   double averageATR = 0;

   for(int i = 1; i <= 14; i++)
     {
      averageATR += iATR(_Symbol, PERIOD_CURRENT, i);
     }
   averageATR /= 14;

// Vérification plus stricte de la volatilité
   if(atr > averageATR * InpvolatilityFactor)
      return false;
   if(atr < averageATR * 0.3)
      return false; // Évite aussi la volatilité trop faible

   return true;
  }


//+------------------------------------------------------------------+
//| Calculate momentum                                                |
//+------------------------------------------------------------------+
double CalculateMomentum()
  {
   int momentumHandle = iMomentum(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   if(momentumHandle == INVALID_HANDLE)
      return 0;

   double momentumBuffer[];
   ArraySetAsSeries(momentumBuffer, true);

   if(CopyBuffer(momentumHandle, 0, 0, 1, momentumBuffer) <= 0)
      return 0;

   double momentum = momentumBuffer[0];
   double rsi = marketAnalysis.rsi; // Utiliser la valeur déjà calculée

   double score = 0;

   if(momentum > 100)
      score += (momentum - 100) / 10;
   if(momentum < 100)
      score -= (100 - momentum) / 10;

   if(rsi > 70)
      score += (rsi - 70) / 5;
   if(rsi < 30)
      score -= (30 - rsi) / 5;

   IndicatorRelease(momentumHandle);
   return MathAbs(score);
  }

//+------------------------------------------------------------------+
//| Calculate correlation score                                       |
//+------------------------------------------------------------------+
double CalculateCorrelationScore()
  {
   if(!EnableCorrelationAnalysis)
      return 0;

   double correlation = 0;
   string symbols[] = {_Symbol}; //{"EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "USDCHF", "NZDUSD", "EURJPY", "GBPJPY", "EURGBP"};

   int validSymbols = 0;
   for(int i = 0; i < ArraySize(symbols); i++)
     {
      if(symbols[i] != _Symbol && SymbolSelect(symbols[i], true))
        {
         double currentCorr = CalculatePairCorrelation(symbols[i]);
         correlation += currentCorr;
         validSymbols++;
        }
     }

   if(validSymbols <= 0)
      return 0;

   return NormalizeDouble(correlation / validSymbols, 2);
  }

//+------------------------------------------------------------------+
//| Calculate pair correlation                                        |
//+------------------------------------------------------------------+
double CalculatePairCorrelation(string symbol)
  {
   int period = 20;
   double price1[], price2[];

   ArraySetAsSeries(price1, true);
   ArraySetAsSeries(price2, true);

   CopyClose(_Symbol, PERIOD_CURRENT, 0, period, price1);
   CopyClose(symbol, PERIOD_CURRENT, 0, period, price2);

   return CalculateCorrelationCoefficient(price1, price2, period);
  }

//+------------------------------------------------------------------+
//| Calculate correlation coefficient                                 |
//+------------------------------------------------------------------+
double CalculateCorrelationCoefficient(double &x[], double &y[], int period)
  {
   double sumX = 0, sumY = 0, sumXY = 0;
   double sumX2 = 0, sumY2 = 0;

   for(int i = 0; i < period; i++)
     {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
      sumY2 += y[i] * y[i];
     }

   double numerator = period * sumXY - sumX * sumY;
   double denominator = MathSqrt((period * sumX2 - sumX * sumX) *
                                 (period * sumY2 - sumY * sumY));

   return denominator == 0 ? 0 : numerator / denominator;
  }

//+------------------------------------------------------------------+
//| Calculate signal confidence                                       |
//+------------------------------------------------------------------+
double CalculateSignalConfidence()
  {
   double confidence = 0;

// Trend alignment contribution (30%)
   confidence += currentSignal.trendAlignment * 30;

// Momentum contribution (20%)
   confidence += currentSignal.momentumScore * 20;

// Volatility contribution (20%)
   confidence += currentSignal.volatilityScore * 20;

// Correlation contribution (30%)
   if(EnableCorrelationAnalysis)
     {
      confidence += currentSignal.correlationScore * 30;
     }

   return MathMin(confidence, 100);
  }

//+------------------------------------------------------------------+
//| Update market sentiment                                           |
//+------------------------------------------------------------------+
void UpdateMarketSentiment()
  {
   if(!EnableMarketSentiment)
      return;

// Calculate market sentiment based on multiple factors
   double sentiment = 0;

// Price action analysis
   sentiment += AnalyzePriceAction() * 30;

// Volume analysis
   sentiment += AnalyzeVolume() * 20;

// Technical indicators
   sentiment += AnalyzeTechnicalIndicators() * 30;

// Market volatility
   sentiment += AnalyzeMarketVolatility() * 20;

   marketAnalysis.marketCondition = DetermineMarketCondition(sentiment);
  }

//+------------------------------------------------------------------+
//| Analyze price action                                              |
//+------------------------------------------------------------------+
double AnalyzePriceAction()
  {
   double close = iClose(_Symbol, PERIOD_CURRENT, 0);
   double open = iOpen(_Symbol, PERIOD_CURRENT, 0);
   double high = iHigh(_Symbol, PERIOD_CURRENT, 0);
   double low = iLow(_Symbol, PERIOD_CURRENT, 0);

   double bodySize = MathAbs(close - open);
   double totalRange = high - low;
   double upperWick = high - MathMax(open, close);
   double lowerWick = MathMin(open, close) - low;

   double score = 0;

// Analyze candle pattern
   if(bodySize > (totalRange * 0.6))
      score += 30; // Strong trend
   if(upperWick < (totalRange * 0.2))
      score += 20; // Little rejection
   if(lowerWick < (totalRange * 0.2))
      score += 20; // Little rejection

   return score;
  }

//+------------------------------------------------------------------+
//| Analyze volume                                                    |
//+------------------------------------------------------------------+
double AnalyzeVolume()
  {
   long currentVolume = iVolume(_Symbol, PERIOD_CURRENT, 0);
   long averageVolume = 0;

// Calculate average volume
   for(int i = 1; i <= 20; i++)
     {
      averageVolume += iVolume(_Symbol, PERIOD_CURRENT, i);
     }
   averageVolume /= 20;

// Score volume
   if(currentVolume > averageVolume * 1.5)
      return 100;
   if(currentVolume > averageVolume * 1.2)
      return 70;
   if(currentVolume > averageVolume)
      return 50;

   return 0.3;
  }

//+------------------------------------------------------------------+
//| Analyze technical indicators                                      |
//+------------------------------------------------------------------+
double AnalyzeTechnicalIndicators()
  {
   double score = 0;

// RSI Analysis
   double rsi = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   if(rsi > 70)
      score -= 0.3;
   else
      if(rsi < 30)
         score += 0.3;
      else
         if(rsi > 60)
            score -= 0.1;
         else
            if(rsi < 40)
               score += 0.1;

// MACD Analysis
   double macd = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
   double signal = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);

   if(macd > signal)
      score += 0.2;
   else
      score -= 0.2;

// Moving Average Analysis
   double ma20 = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
   double ma50 = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
   double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);

   if(currentPrice > ma20 && ma20 > ma50)
      score += 30;
   else
      if(currentPrice < ma20 && ma20 < ma50)
         score -= 30;

   return score;
  }

//+------------------------------------------------------------------+
//| Analyze market volatility                                         |
//+------------------------------------------------------------------+
double AnalyzeMarketVolatility()
  {
   double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
   double averageATR = 0;

// Calculate average ATR
   for(int i = 1; i <= 14; i++)
     {
      averageATR += iATR(_Symbol, PERIOD_CURRENT, 14);
     }
   averageATR /= 14;

// Score volatility
   if(atr > averageATR * 1.5)
      return 30; // High volatility
   if(atr < averageATR * 0.5)
      return 80; // Low volatility
   return 0.5; // Normal volatility
  }

//+------------------------------------------------------------------+
//| Determine market condition                                        |
//+------------------------------------------------------------------+
string DetermineMarketCondition(double sentiment)
  {
   if(sentiment > 70)
      return "Strong Bullish";
   if(sentiment > 30)
      return "Moderately Bullish";
   if(sentiment > -30)
      return "Neutral";
   if(sentiment > -70)
      return "Moderately Bearish";
   return "Strong Bearish";
  }

//+------------------------------------------------------------------+
//| Check trading conditions                                          |
//+------------------------------------------------------------------+
bool CheckTradingConditions()
  {
// Check spread
   double currentSpread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(currentSpread > MaxSpreadPoints)
     {
      Print("Spread too high: ", currentSpread);
      return false;
     }

// Check risk levels
   if(!riskManager.CheckRiskLevels())
     {
      Print("Risk levels exceeded");
      return false;
     }

// Check volatility
   if(UseVolatilityFilter)
     {
      double volatility = CalculateVolatility();
      if(volatility > 20)
        {
         Print("Volatility too high: ", volatility);
         return false;
        }
     }

// Check multi-timeframe confirmation
   if(RequireMultiTimeframeConfirmation)
     {
      if(!CheckMultiTimeframeConfirmation())
        {
         Print("Multi-timeframe confirmation failed");
         return false;
        }
     }

// Check free margin
   if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) <= 0)
     {
      Print("Insufficient free margin");
      return false;
     }

// Check if we can trade
   if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE))
     {
      Print("Trading not allowed for this symbol");
      return false;
     }

   double volume = CalculatePositionSize();
   if(PositionsTotal() >= MaxOpenPositions)
     {
      return NULL;
     }
   if(currentSignal.type == SIGNAL_BUY)
     {
      Print("Opening buy position");
      OpenBuyPosition(volume);
     }
   else
     {
      Print("Opening sell position");
      OpenSellPosition(volume);
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Check multi-timeframe confirmation                                |
//+------------------------------------------------------------------+
bool CheckMultiTimeframeConfirmation()
  {
   ENUM_TIMEFRAMES timeframes[] = {PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};
   int confirmations = 0;

   for(int i = 0; i < ArraySize(timeframes); i++)
     {
      if(CheckTimeframeTrend(timeframes[i]) == currentSignal.type)
        {
         confirmations++;
        }
     }

   return confirmations >= InpMultiTimeFrameConfirmations;
  }

//+------------------------------------------------------------------+
//| Check timeframe trend                                             |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE CheckTimeframeTrend(ENUM_TIMEFRAMES timeframe)
  {
   double ma20 = iMA(_Symbol, timeframe, 20, 0, MODE_SMA, PRICE_CLOSE);
   double ma50 = iMA(_Symbol, timeframe, 50, 0, MODE_SMA, PRICE_CLOSE);
   double currentPrice = iClose(_Symbol, timeframe, 0);

   if(currentPrice > ma20 && ma20 > ma50)
      return SIGNAL_BUY;
   if(currentPrice < ma20 && ma20 < ma50)
      return SIGNAL_SELL;

   return SIGNAL_NONE;
  }

//+------------------------------------------------------------------+
//| Calculate trend signal                                            |
//+------------------------------------------------------------------+
double CalculateTrendSignal(ENUM_TIMEFRAMES timeframe) {
    double signal = 0;
    
    double ma20 = iMA(_Symbol, timeframe, 20, 0, MODE_SMA, PRICE_CLOSE);
    double ma50 = iMA(_Symbol, timeframe, 50, 0, MODE_SMA, PRICE_CLOSE);
    double currentPrice = iClose(_Symbol, timeframe, 0);
    
    // Réduire l'impact des MA
    if(currentPrice > ma20) signal += 20;
    if(currentPrice > ma50) signal += 20;
    if(ma20 > ma50) signal += 25;
    
    // Ajouter analyse de la pente
    double ma20Slope = (ma20 - iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE)) / _Point;
    if(ma20Slope > 0) signal += 15;
    
    return signal;
}

//+------------------------------------------------------------------+
//| Calculate momentum signal                                         |
//+------------------------------------------------------------------+
double CalculateMomentumSignal()
  {
   double rsi = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   double macd = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
   double signal = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);

   double momentumSignal = 0;

// RSI analysis
   if(rsi > 70)
      momentumSignal -= 40;
   else
      if(rsi < 30)
         momentumSignal += 40;
      else
         if(rsi > 60)
            momentumSignal -= 20;
         else
            if(rsi < 40)
               momentumSignal += 20;

// MACD analysis
   if(macd > signal)
      momentumSignal += 30;
   else
      momentumSignal -= 30;

// MACD histogram strength
   double histogram = macd - signal;
   if(MathAbs(histogram) > 0.0020)
      momentumSignal *= 1.2;

   return momentumSignal;
  }

//+------------------------------------------------------------------+
//| Calculate volume signal                                           |
//+------------------------------------------------------------------+
double CalculateVolumeSignal()
  {
   long currentVolume = iVolume(_Symbol, PERIOD_CURRENT, 0);
   long previousVolume = iVolume(_Symbol, PERIOD_CURRENT, 1);
   long averageVolume = 0;

// Calculate average volume
   for(int i = 1; i <= 20; i++)
     {
      averageVolume += iVolume(_Symbol, PERIOD_CURRENT, i);
     }
   averageVolume /= 20;

   double volumeSignal = 0;

// Volume increase analysis
   if(currentVolume > previousVolume * 1.5)
      volumeSignal += 40;
   else
      if(currentVolume > previousVolume * 1.2)
         volumeSignal += 20;

// Volume vs average analysis
   if(currentVolume > averageVolume * 1.5)
      volumeSignal += 40;
   else
      if(currentVolume > averageVolume * 1.2)
         volumeSignal += 20;

// Price-volume relationship
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 0);
   double previousClose = iClose(_Symbol, PERIOD_CURRENT, 1);

   if(currentClose > previousClose && currentVolume > previousVolume)
     {
      volumeSignal += 0.2;
     }
   else
      if(currentClose < previousClose && currentVolume > previousVolume)
        {
         volumeSignal -= 0.2;
        }

   return volumeSignal;
  }

//+------------------------------------------------------------------+
//| Calculate trend alignment                                         |
//+------------------------------------------------------------------+
double CalculateTrendAlignment()
  {
   double alignment = 0;
   ENUM_TIMEFRAMES timeframes[] = {PERIOD_M15, PERIOD_H1, PERIOD_H4, PERIOD_D1};

   for(int i = 0; i < ArraySize(timeframes); i++)
     {
      if(CheckTimeframeTrend(timeframes[i]) == currentSignal.type)
        {
         alignment += 0.25;
        }
     }

   return alignment;
  }

//+------------------------------------------------------------------+
//| Calculate volatility score                                        |
//+------------------------------------------------------------------+
double CalculateVolatilityScore()
  {
   double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
   double averageATR = 0;

   for(int i = 1; i <= 14; i++)
     {
      averageATR += iATR(_Symbol, PERIOD_CURRENT, 14);
     }
   averageATR /= 14;

   if(atr < averageATR * 0.5)
      return 90; // Low volatility is good
   if(atr < averageATR * 0.8)
      return 70;
   if(atr < averageATR * 1.2)
      return 50;
   if(atr < averageATR * 1.5)
      return 30;
   return 0.1; // High volatility is risky
  }

//+------------------------------------------------------------------+
//| Calculate momentum score                                          |
//+------------------------------------------------------------------+
double CalculateMomentumScore()
  {
   double rsi = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   double macd = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
   double signal = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);

   double score = 0;

// RSI contribution
   if(currentSignal.type == SIGNAL_BUY)
     {
      if(rsi < 30)
         score += 40;
      else
         if(rsi < 40)
            score += 20;
         else
            if(rsi > 70)
               score -= 40;
     }
   else
     {
      if(rsi > 70)
         score += 40;
      else
         if(rsi > 60)
            score += 20;
         else
            if(rsi < 30)
               score -= 40;
     }

// MACD contribution
   if(currentSignal.type == SIGNAL_BUY)
     {
      if(macd > signal)
         score += 30;
      if(macd > 0)
         score += 30;
     }
   else
     {
      if(macd < signal)
         score += 30;
      if(macd < 0)
         score += 30;
     }

   return MathMax(0, MathMin(1, score));
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

// Release indicator handles
   IndicatorRelease(rsiHandle);
   IndicatorRelease(macdHandle);
   IndicatorRelease(atrHandle);
   IndicatorRelease(ma20Handle);
   IndicatorRelease(ma50Handle);

// Clean up objects
   ObjectsDeleteAll(0);

   ChartRedraw();
  }
//+------------------------------------------------------------------+
