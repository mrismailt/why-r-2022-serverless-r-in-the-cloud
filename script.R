#### ONE ####
logger::log_info("Starting script")
box::use(magrittr[`%>%`])
dotenv::load_dot_env()
bucket_input <- "whyr2022input"
bucket_output <- "whyr2022output"

#### TWO ####
logger::log_info("Pulling latest file from {bucket_input}")
latest_file <- aws.s3::get_bucket(bucket_input) %>%
  tibble::as_tibble() %>%
  dplyr::filter(!stringr::str_detect(Key, "\\-used\\_")) %>%
  dplyr::arrange(dplyr::desc(LastModified)) %>%
  dplyr::slice(1) %>%
  dplyr::pull(Key) %>%
  stringr::str_replace("\\.rds", "")
logger::log_info("Latest file from {bucket_input} pulled: {latest_file}.rds")

#### THREE ####
logger::log_info("Creating scatter plot")
s3_uri <- glue::glue("s3://{bucket_input}/{latest_file}.rds")
plot <- aws.s3::s3readRDS(s3_uri) %>%
  setNames(c("x", "y")) %>%
  ggplot2::ggplot(ggplot2::aes(x, y)) +
  ggplot2::geom_point() +
  ggplot2::ggtitle(latest_file)
image_file <- glue::glue("output_{latest_file}.png")

#### FOUR ####
logger::log_info("Saving plot as image: {image_file}")
ggplot2::ggsave(image_file, plot) %>%
  suppressWarnings() %>%
  suppressMessages()

#### FIVE ####
logger::log_info("Pushing image to {bucket_output}")
aws.s3::put_object(image_file, image_file, bucket_output) %>%
  invisible()

#### SIX ####
logger::log_info("Marking {latest_file}.rds as used")
aws.s3::copy_object(glue::glue("{latest_file}.rds"), glue::glue("{latest_file}-used_{Sys.time()}.rds"), from_bucket = bucket_input, to_bucket = bucket_input) %>%
  invisible()
aws.s3::delete_object(glue::glue("{latest_file}.rds"), bucket = bucket_input) %>%
  invisible()

#### END ####
logger::log_success("{image_file} created from {latest_file}.rds and pushed to {bucket_output}")
