library(data.table)

hpc <- fread("./household_power_consumption.txt", na.strings="?")
hpc <- hpc[(hpc$Date=='1/2/2007' | hpc$Date=='2/2/2007'),]
gap <- as.numeric(hpc$Global_active_power)
getDateTime = function(d, t) {
  paste(d, t, sep=" ")
}
dt <- mapply(getDateTime, hpc$Date, hpc$Time)
dtp <- sapply(dt, as.POSIXct, format="%d/%m/%Y %H:%M:%S")
dtp <- as.POSIXlt(dtp, origin="1970-01-01")

png(filename="./plot2.png", width=480, height=480)
ylabel <- "Global Active Power (kilowatts)"
plot(dtp, gap, xlab="", ylab=ylabel, type="l")
dev.off()
