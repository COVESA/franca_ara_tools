package org.genivi.faracon.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.UUID;

public class NamedUUIDGenerator {

	public static UUID makeUUID(String seed) {
		MessageDigest md = null;
		try {
			md = MessageDigest.getInstance("SHA-256");
		} catch (NoSuchAlgorithmException ex) {
			return null;
		}
		
		md.update(seed.getBytes());
		
		byte[] data = Arrays.copyOfRange(md.digest(), 0, 16); 
	    long msb = 0;
        for (int i = 0; i < 8; i++) {
            msb = (msb << 8) | (data[i] & 0xff);
        }
        long lsb = 0; 
        for (int i = 8; i < 16; i++) {
            lsb = (lsb << 8) | (data[i] & 0xff);
        }
 
        return new UUID(msb, lsb);
	}
}
