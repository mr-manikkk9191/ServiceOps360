/** Pure utility: great-circle (Haversine) distance. No SOQL/DML, so trivially testable. */
public with sharing class GeoUtil {
    private static final Double EARTH_RADIUS_KM = 6371;

    public static Double distanceKm(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2) {
        if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
            return null;
        }
        Double la1 = lat1.doubleValue();
        Double la2 = lat2.doubleValue();
        Double dLat = toRad(la2 - la1);
        Double dLon = toRad(lon2.doubleValue() - lon1.doubleValue());
        Double a = Math.pow(Math.sin(dLat / 2), 2) + Math.cos(toRad(la1)) * Math.cos(toRad(la2)) * Math.pow(Math.sin(dLon / 2), 2);
        Double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_KM * c;
    }

    private static Double toRad(Double degrees) {
        return degrees * Math.PI / 180;
    }
}
