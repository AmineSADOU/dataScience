library(data.table)

hpc <- fread("./household_power_consumption.txt", na.strings="?")
hpc <- hpc[(hpc$Date=='1/2/2007' | hpc$Date=='2/2/2007'),]
gap <- as.numeric(hpc$Global_active_power)

png(filename="./plot1.png", width=480, height=480)
heading <- "Global Active Power" ; xlabel <- "Global Active Power (kilowatts)"
hist(gap, col="red", main=heading, xlab=xlabel)
dev.off()
