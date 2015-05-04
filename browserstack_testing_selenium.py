from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

import time

#desired_cap = {'os': 'Windows', 'os_version': 'xp', 'browser': 'IE', 'browser_version': '7.0' }


desired_cap={
'iPhone5_iOS6_1': {
                             'platform' : 'MAC',
                                      "browserName" : "iPhone",
                                      "device" : "iPhone 5",
                                      "browserstack.debug" : "true"
                  },
'iPhone5C_iOS7':  {
                                      "platform" : "MAC",
                                      "browserName" : "iPhone",
                                      "device" : "iPhone 5C",
                                      "browserstack.debug" : "true"
                  },
                 'iPhone5S_iOS7'  : {
                                      "platform" : "MAC",
                                      "browserName" : "iPhone",
                                      "device" : "iPhone 5S",
                                      "browserstack.debug" : "true"
                                     },

                 'GalaxyS4_4_3'   : {
                                      "browserName" : "android",
                                      "platform" : "ANDROID",
                                      "device" : "Samsung Galaxy S4",
                                      "browserstack.debug" : "true"
                                     },

                 'GalaxyS5_4_4'   : {
                                      "browserName" : "android",
                                      "platform" : "ANDROID",
                                      "device" : "Samsung Galaxy S5",
                                      "browserstack.debug" : "true"
                                     },
'Nexus_5':{
'browserName': 'android', 'platform': 'ANDROID', 'device': 'Google Nexus 5'
} 
 }



for key in desired_cap:
  driver = webdriver.Remote(
      command_executor='http://algiskukenas1:ksqgGzp1eFyDyA3LLhEC@hub.browserstack.com:80/wd/hub',
      desired_capabilities=desired_cap[key])

#  driver.get("http://www.google.com")
#  if not "Google" in driver.title:
#      raise Exception("Unable to load google page!")
#  elem = driver.find_element_by_name("q")
#  elem.send_keys("BrowerStack")
#  elem.submit()
#  print driver.title

  driver.get("http://www.google.com")
#  driver.get("http://www.info-watch.com/")
  time.sleep(10)
  driver.save_screenshot('screenshot.png')
  driver.quit()
