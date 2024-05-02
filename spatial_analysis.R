# Load libraries 
library(RPostgres)
library(ggplot2)
library(dplyr)

# Connect to the PostgreSQL database
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "PalmOilProject",
  host = "localhost",
  port = 5432,
  user = " ",
  password = " "
)

# Retrieve data from the database 
data <- dbGetQuery(con, "SELECT * FROM economic_variables")
school_attendance <- dbGetQuery(con, "SELECT * FROM school_attendance_clean")
poverty <- dbGetQuery(con, "SELECT * FROM employed_in_poverty_clean")
electricity <- dbGetQuery(con, "SELECT * FROM household_electricity_clean")

# Merge data into one table 
merged_data <- merge(data, school_attendance, by = "province")
merged_data2 <- merge(merged_data, poverty, by = "province")
merged_data3 <- merge(data, electricity, by = "province")

# Filter out rows where either number_of_smallholder_plantations or percentage_employed is 0
filtered_data <- merged_data3 %>%
  filter(number_of_smallholder_plantations !=0)

# create proportion of households without electricity 
merged_data3$proportion_without_electricity <- merged_data3$without_electricity / merged_data3$total_electricity 

# Create stacked bar chart
ggplot(data, aes(x = province)) +
  geom_bar(aes(y = number_of_smallholder_plantations), stat = "identity", fill = "#0072B2", alpha = 0.8) +
  geom_bar(aes(y = number_of_plantations), stat = "identity", fill = "#D55E00", alpha = 0.8) +
  labs(x = "Province", y = "Number of Plantations", fill = NULL) +
  ggtitle("Comparison of Smallholder and Total Plantations by Province") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title = element_text(size = 12),
        plot.title = element_text(size = 14, face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(color = "black"))


# Create scatter plot with filtered data
ggplot(filtered_data, aes(x = number_of_smallholder_plantations, y = proportion_without_electricity)) +
  geom_point(color = "#0072B2", alpha = 0.8) +  # Set color and transparency
  geom_smooth(method = "lm", se = FALSE, color = "#D55E00") + 
  labs(x = "Number of Smallholder Plantations", y = "Proportion without Electricity") +
  ggtitle("Scatterplot of Households Without Electricity and Number of Smallholder Plantations") +
  theme_minimal()
  