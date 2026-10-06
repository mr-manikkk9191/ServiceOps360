@IsTest
private class GeoUtilTest {
    @IsTest static void chandigarhToDelhiIsAbout240Km() {
        Double d = GeoUtil.distanceKm(30.7333, 76.7794, 28.6139, 77.2090);
        System.assert(d > 230 && d < 250, 'Expected ~238 km but got ' + d);
    }
    @IsTest static void missingCoordinatesReturnNull() {
        System.assertEquals(null, GeoUtil.distanceKm(null, 76.7, 28.6, 77.2));
    }
    @IsTest static void samePointIsZero() {
        System.assert(GeoUtil.distanceKm(30.7, 76.7, 30.7, 76.7) < 0.001);
    }
}
