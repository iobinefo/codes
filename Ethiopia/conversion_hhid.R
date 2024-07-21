

completed21 <- read_dta("Project/codes/Ethiopia/Ethiopia_wave5/completed21.dta")

# Install the bit64 package if not already installed
install.packages("bit64")

install.packages("haven")

# Load the bit64 package
library(bit64)
library(haven)

install.packages("writexl")
library(writexl)

# Convert character vector to integer64
completed21$hhid1 <- as.integer64(completed21$hhid)

View(completed21)

# Check the class of a specific column
print(class(completed21$hhid1))


# Save the data frame as a Stata file
write_dta(completed21, "Project/codes/Ethiopia/Ethiopia_wave5/completed211.dta")

# Save the data frame as an Excel file
write_xlsx(completed21, "Project/codes/Ethiopia/Ethiopia_wave5/completed211.xlsx")

write.csv(completed21, "Project/codes/Ethiopia/Ethiopia_wave5/completed21.csv", row.names = FALSE)

# Verify the result
head(completed21$hhid1)



















# Generate a dummy variable
completed21$dummy <- 1

# Collapse and summarize by hhid1
library(dplyr)

df_summary <- completed21 %>%
  group_by(hhid1) %>%
  summarise(dummy_sum = sum(dummy))

# Tabulate the dummy variable
table(completed21$dummy)

# Keep rows where dummy is equal to 4
df_filtered <- completed21[completed21$dummy == 4, ]

# Tabulate the dummy variable
table(completed21$dummy)

