from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import unittest
import os

TEST_URL = os.getenv('TEST_URL', 'magento1developmentenvironment.hypernode.local')

class MyTestCase(unittest.TestCase):

    def setUp(self):
        self.browser = webdriver.PhantomJS()
        self.addCleanup(self.browser.quit)

    def test_magento_in_source(self):
        url = "http://" + TEST_URL + '/index.php/install'
        self.browser.get(url)
        self.assertIn('Magento Installation Wizard', self.browser.page_source)

if __name__ == '__main__':
    unittest.main(verbosity=2)
