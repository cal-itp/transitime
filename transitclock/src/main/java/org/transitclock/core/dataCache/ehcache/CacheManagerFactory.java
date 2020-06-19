package org.transitclock.core.dataCache.ehcache;

import java.net.URL;

import org.ehcache.CacheManager;
import org.ehcache.config.builders.CacheManagerBuilder;
import org.ehcache.xml.XmlConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CacheManagerFactory {
	private static final Logger logger = LoggerFactory.getLogger(CacheManagerFactory.class);

	public static CacheManager singleton = null;

	public static CacheManager getInstance() {
		logger.info("CacheManagerFactory.getInstance()");
		logger.info("- singleton: {}", singleton);

		if (singleton == null) {
			URL xmlConfigUrl = CacheManagerFactory.class.getClassLoader().getResource("ehcache.xml");
			logger.info("- xmlConfigUrl: {}", xmlConfigUrl);
			XmlConfiguration xmlConfig = new XmlConfiguration(xmlConfigUrl);
			logger.info("- xmlConfig: {}", xmlConfig);

			singleton = CacheManagerBuilder.newCacheManager(xmlConfig);
			logger.info("- singleton: {}", singleton);
			singleton.init();
			logger.info("+ singleton initialized");
		}

		return singleton;
	}
}
