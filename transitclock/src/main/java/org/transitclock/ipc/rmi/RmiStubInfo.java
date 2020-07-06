/*
 * This file is part of Transitime.org
 *
 * Transitime.org is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License (GPL) as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Transitime.org is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Transitime.org .  If not, see <http://www.gnu.org/licenses/>.
 */
package org.transitclock.ipc.rmi;

import org.transitclock.configData.RmiConfig;
import org.transitclock.db.webstructs.WebAgency;
import org.transitclock.utils.Time;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Contains the info needed for creating an RMI stub, including the agency ID
 * and the agency host name. The hostname is obtained from the Java property
 * transitclock.rmi.rmiHost if set. Otherwise gets the host names from the
 * WebAgency database.
 * <p>
 * This information exists on the client side.
 *
 * @author SkiBu Smith
 *
 */
public class RmiStubInfo {

	final String agencyId;
	final String className;
	private int hostNumber = -1;

	private static final Logger logger = LoggerFactory
			.getLogger(RmiStubInfo.class);

	/********************** Member Functions **************************/

	public RmiStubInfo(String agencyId, String className) {
		this.agencyId = agencyId;
		this.className = className;
	}

	public String getAgencyId() {
		return agencyId;
	}

	public String getClassName() {
		return className;
	}

	/**
	 * Returns the RMI hostname. Will use command line parameter
	 * -Dtransitclock.core.rmiHost if it is set. If not set then looks in
	 * WebAgencies table in the web database. Returns null if not configured.
	 *
	 * @param rereadIfOlderThanMsecs
	 *            If web agencies read from db more than this time ago then they
	 *            are read in again. Set to a high value such as
	 *            Integer.MAX_VALUE if there is no indication of a problem, such
	 *            as when a ClientFactory is first setup. But if there is a
	 *            problem communicating via RMI then should use a small value
	 *            such as 30 seconds so that the system will read in possibly
	 *            new host name from the database, yet not read db for every
	 *            problematic request.
	 * @return The host name, or null if agency not configured
	 */
	private String getHostName(int rereadIfOlderThanMsecs) {
		logger.info("RmiStubInfo.getHostName()");

		// If RMI host is configured in RmiConfig via command line
		// option then use it.
		String configuredRmiHost = RmiConfig.rmiHost();
		logger.info("- configuredRmiHost: {}", configuredRmiHost);
		if (configuredRmiHost != null)
			return configuredRmiHost;

		// RMI host not configured via command line so use value
		// from database.
		WebAgency webAgency =
				WebAgency.getCachedWebAgency(agencyId, rereadIfOlderThanMsecs);
		logger.info("- webAgency: {}", webAgency);

		if (webAgency == null) return null;

		logger.info("- webAgency.getHostName(): {}", webAgency.getHostName());

		/*// ### very ugly hack to get local rmi registry for agency
		// For testing only, heavily depends on container starting
		// sequence and other things
		String[] args = webAgency.getHostName().split("\\.");
		StringBuilder sb = new StringBuilder();

		for (int i=0; i<args.length-1; i++) {
			sb.append(args[i]);
			sb.append('.');
		}

		if (hostNumber < 0) {
			hostNumber = Integer.parseInt(args[args.length - 1]) + 1;
		} else {
			hostNumber += 2;
		}

		sb.append(hostNumber);
		logger.info("- sb(): {}", sb);


		return sb.toString();*/

		if (agencyId.equals("halifax")) {
			return "172.17.0.4";
		} else if (agencyId.equals("monterey")) {
			return "172.17.0.6";
		} else {
			return null;
		}
	}

	/**
	 * Returns the RMI hostname that is cached. Will not update the cache even
	 * if agency not in cache and cache not updated for a long time. Will use
	 * command line parameter -Dtransitclock.core.rmiHost if it is set. If not set
	 * then looks in cached version of WebAgencies table from the web database.
	 * Returns null if agency not configured.
	 *
	 * @return The host name, or null if agency doesn't exist
	 */
	public String getHostName() {
		return getHostName(Integer.MAX_VALUE);
	}

	/**
	 * Intended for when communication was working but now is not in that this
	 * method will get updated hostname data from db if cache is somewhat old.
	 * Returns the RMI hostname. Will use command line parameter
	 * -Dtransitclock.core.rmiHost if it is set. If not set then looks in cached
	 * version of WebAgencies table from the web database. If cached data is
	 * more than 30 seconds old then will reread WebAgency data from db. Returns
	 * null if agency not configured.
	 *
	 * @return The host name, or null if agency doesn't exist
	 */
	public String getHostNameViaUpdatedCache() {
		return getHostName(30 * Time.SEC_IN_MSECS);
	}
}
