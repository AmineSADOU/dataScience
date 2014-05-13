library(data.table)

hpc <- fread("./household_power_consumption.txt", na.strings="?")
hpc <- hpc[(hpc$Date=='1/2/2007' | hpc$Date=='2/2/2007'),]
sub1 <- as.numeric(hpc$Sub_metering_1)
sub2 <- as.numeric(hpc$Sub_metering_2)
sub3 <- as.numeric(hpc$Sub_metering_3)
getDateTime = function(d, t) {
  paste(d, t, sep=" ")
}
dt <- mapply(getDateTime, hpc$Date, hpc$Time)
dtp <- sapply(dt, as.POSIXct, format="%d/%m/%Y %H:%M:%S")
dtp <- as.POSIXlt(dtp, origin="1970-01-01")

png(filename="./plot3.png", width=480, height=480)
ylabel <- "Energy sub metering"
plot(dtp, sub1, xlab="", ylab=ylabel, type="n")
lines(dtp, sub1) ; lines(dtp, sub2, col="red") ; lines(dtp, sub3, col="blue")
legend("topright", lty=1, col=c("black", "red", "blue"), legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
dev.off()
