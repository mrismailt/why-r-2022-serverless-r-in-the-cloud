box::use(magrittr[`%>%`])

dotenv::load_dot_env()

bucket_input <- "whyr2022test"
bucket_output <- "whyr2022testoutput"

latest_file <- aws.s3::get_bucket(bucket_input) %>%
  tibble::as_tibble() %>%
  dplyr::arrange(dplyr::desc(LastModified)) %>%
  dplyr::slice(1) %>%
  dplyr::pull(Key) %>%
  stringr::str_replace("\\.rds", "")

logger::log_info("Pulling latest file from {bucket_input}: {latest_file}")

s3_uri <- glue::glue("s3://{bucket_input}/{latest_file}.rds")

logger::log_info("Creating scatter plot")

plot <- aws.s3::s3readRDS(s3_uri) %>%
  setNames(c("x", "y")) %>%
  ggplot2::ggplot(ggplot2::aes(x, y)) +
  ggplot2::geom_point() +
  ggplot2::ggtitle(latest_file)

image_file <- glue::glue("output_{latest_file}.png")

logger::log_info("Saving image: {image_file}")

ggplot2::ggsave(image_file, plot)

logger::log_info("Pushing image to {bucket_output}")

aws.s3::put_object(image_file, image_file, bucket_output) %>%
  suppressMessages() %>%
  invisible()

logger::log_success("{image_file} created from {latest_file} and pushed to {bucket_output}")