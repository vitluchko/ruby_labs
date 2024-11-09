# Web Scraping Plan

## 1. Website Selection

We will be performing web scraping on a website that allows scraping according to its terms of use. After reviewing the site's robots.txt file and its Terms of Service, we confirm that scraping is permitted on the following website:

**Website URL:** [https://fakestoreapi.com/](https://fakestoreapi.com/)

- The website provides an open API for developers, but it also allows scraping in a limited manner. We will respect the rules outlined in their terms and conditions to ensure compliance.

## 2. Data to Collect

We will be scraping the following data from the website:

- **ID**: The unique identifier for the product (e.g., SKU or product ID).
- **Title**: The name of the product.
- **Price**: The price of the product.
- **Category**: The category under which the product is listed (e.g., Electronics, Clothing).
- **Image URL**: The URL of the product's main image.
- **Rating**: The average rating of the product (if available).
  - **Rate**: The numerical rating score (e.g., 4.5 out of 5).
  - **Count**: The number of reviews or ratings the product has received.

## 3. Pages to Scrape

We will scrape the following pages on the website:

- **Home Page**: Starting point for scraping, will list main categories or featured content.
- **Category Pages**: Pages that list items by category (e.g., "Electronics," "Clothing," "Blog Posts").
- **Product or Article Detail Pages**: The detailed pages for each product or article, which contain more in-depth information.
- **Pagination**: If applicable, we will collect the content from paginated pages (e.g., the second, third, etc. page of a list).

### Examples of pages:
- [https://example.com/products](https://example.com/products)
- [https://example.com/category/electronics](https://example.com/category/electronics)
- [https://example.com/category/clothing](https://example.com/category/clothing)

## 4. Navigating Between Pages

To efficiently collect data from multiple pages, we will use the following methods:

### Pagination:
- If a category page (e.g., products or articles) contains multiple pages, we will scrape each page by following the "Next" page link.
- We will implement logic to detect and follow pagination links to retrieve all available data from all pages.

### Links to Detail Pages:
- We will collect links to individual product or article detail pages from the category page or the home page and scrape the detailed data from those pages.
- These detail pages contain more specific information (e.g., product descriptions, reviews, full article text).

### URL Structure:
- The URLs of the pages will follow a structured pattern. For example, the next page URL could look like `https://example.com/category/electronics?page=2`, and we will extract data from each page by iterating over the URL with incremented page numbers.

## 5. Tools and Libraries

We will use the following tools and libraries to perform web scraping:

- **Ruby Gems**: 
  - `Nokogiri`: For parsing HTML and XML.
  - `HTTParty`: To send HTTP requests.
  - `Faraday`: As an HTTP client for making requests with retries.
  - `Oj`: For fast JSON parsing.
  - `Colorize`: For pretty-printing output in the console.
- **Rake Tasks**: We will organize scraping tasks as Rake tasks for easy automation and scheduling.

## 6. Rate Limiting and Ethical Considerations

To ensure compliance with the website’s terms and prevent overloading their servers, we will:

- Respect the robots.txt file and avoid scraping disallowed pages.
- Implement a delay between requests to reduce server load.
- Limit the number of requests per minute to avoid triggering rate limits or denial of service.

## 7. Handling Errors and Logging

During the scraping process, we will log errors and retry failed requests. All scraping activities will be logged to the `logs/application.log` file to monitor progress and troubleshoot any issues.

## 8. Output Format

The scraped data will be saved in the following formats:

- **CSV**: For tabular data such as product prices and article titles.
- **JSON**: For structured data such as product details and article metadata.

All output files will be saved in the `output/` directory.

## 9. License

This project is intended for personal and educational use. Please ensure you have permission to scrape the website you are working with and follow ethical scraping practices.
