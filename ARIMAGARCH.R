install.packages("googlesheets4")
install.packages("googledrive")
library(googlesheets4)
library(googledrive)
library(easypackages)
library(rugarch)
library(ggplot2)
libraries('astsa', 'TSA', 'forecast', 'urca', 'moments', 'vioplot', 'tseries')

datos<-data.frame(datos)
head(datos)
datos <- subset(datos, !is.na(VU) & VU != "")
#datos$VU <- gsub("[^0-9,]", "", datos$VU)
#datos$VU <- gsub(",", ".", datos$VU)
#datos$VU <- as.numeric(datos$VU)
head(datos)
str(datos$VU)
# Convertir FECHA a formato Date
datos$FECHA <- as.Date(datos$FECHA,format="%d/%m/%Y")
datos <- datos[rev(1:nrow(datos)), ]

(x <- ts(datos$VU, start = c(2023, 348), frequency = 365))                                            # Create time-series objects
###################### Descriptive Statistics ######################
(stats <- data.frame(
  Mean      = mean(x),
  Median    = median(x),
  Variance  = var(x),
  SD        = sd(x),
  Min       = min(x),
  Q1        = quantile(x, 0.25),
  Q3        = quantile(x, 0.75),
  Max       = max(x),
  Skewness  = skewness(x),
  Kurtosis  = kurtosis(x)))
ts.plot(x, xlab='', ylab='VAlOR UNIDAD DIARIA', main='')
y<-log(x)
ydif<-diff(y)
plot(ydif)


# ARIMA(3,1,3) + GARCH(1,1)
# Metodología Box–Jenkins simplificada

# ---- 1) x ya es ts ----
print(summary(x))
plot(x, main = "VU original", ylab = "x", xlab = "Tiempo")

# ---- 2) Ajuste ARIMA(3,1,3) ----
fit_arima <- Arima(x, order = c(3,1,3), include.constant = FALSE, method = "ML", lambda = 0)
summary(fit_arima)

# ---- 3) Diagnóstico de residuos ----
resid_arima <- residuals(fit_arima)

par(mfrow = c(2,2))
ts.plot(x)
lines(fit_arima$fitted, col=2)
plot(resid_arima, main = "Residuos ARIMA(3,1,3)")
abline(h=0,col=2)
acf(resid_arima, main = "ACF residuos")
qqnorm(resid_arima); qqline(resid_arima)
par(mfrow = c(1,1))

Box.test(resid_arima, lag = 14, type = "Ljung-Box")

# ---- 4) Ajuste GARCH(1,1) a los residuos ----
spec_garch <- ugarchspec(
  mean.model     = list(armaOrder = c(3,3), include.mean = FALSE),
  variance.model = list(model = "sGARCH", garchOrder = c(1,1), variance.targeting=TRUE),
  distribution.model = "std"
)

fit_garch <- ugarchfit(spec_garch, data = as.numeric(ydif))
fit_garch
mu<-fit_garch@fit$fitted.values
mu
ts.plot(mu)

sigma<-fit_garch@fit$sigma #riesgo-volatilidad 
ts.plot(sigma, main="volatilidad estimada")
inversion<-26318000
VaR<-(mu+qnorm(0.05)*sigma)*inversion
VaR
mean(VaR)
ts.plot(-VaR)
