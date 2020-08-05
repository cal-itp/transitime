import java.io.*;
import java.util.*;

// 101 I,34.59883,-120.41754,296
public class CheckShapes {
    public static void main(String[] arg) throws Exception {
        BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream(arg[0])));

        int shapeIndexDeltaSum, shapeIndexDeltaMin, shapeIndexDeltaMax;
        float distanceSum, distanceMin, distanceMax;

        int prevShapIndex = -1;
        float prevLat = 0;
        float prevLong = 0;
        String previousID = null;

        distanceSum = 0;
        distanceMin = 1000;
        distanceMax = -1000;

        shapeIndexDeltaSum = 0;
        shapeIndexDeltaMin = 1000;
        shapeIndexDeltaMax = -1000;

        int count = 0;

        // skip CSV header
        in.readLine();

        for (;;) {
            String line = in.readLine();
            if (line == null) break;

            String[] split = line.split(",");

            int shapeIndex = Integer.parseInt(split[3]);
            float lat = Float.parseFloat(split[1]);
            float lon = Float.parseFloat(split[2]);
            String id = split[0];

            if (id.equals(previousID)) {
                int indexDelta = shapeIndex - prevShapIndex;

                if (shapeIndex != prevShapIndex + 1) {
                    System.out.println(String.format("%d: shape index jump: %d -> %d", count + 1, prevShapIndex, shapeIndex));
                }

                shapeIndexDeltaSum += indexDelta;

                if (indexDelta < shapeIndexDeltaMin) shapeIndexDeltaMin = indexDelta;
                if (indexDelta > shapeIndexDeltaMax) shapeIndexDeltaMax = indexDelta;

                float latd = lat - prevLat;
                float lond = lon - prevLong;

                float distance = (float)Math.sqrt(latd * latd + lond * lond);

                /*if (distance > .003) {
                    System.out.println(String.format("%d: distance: %f", count + 1, distance));
                }*/

                distanceSum += distance;

                if (distance < distanceMin) distanceMin = distance;
                if (distance > distanceMax) distanceMax = distance;
            } else {
                System.out.println("shape ID: " + id);
            }

            prevShapIndex = shapeIndex;
            prevLat = lat;
            prevLong = lon;
            previousID = id;

            count++;
        }

        System.out.println(String.format("shape index delta min/avg/max: %d/%d/%d", shapeIndexDeltaMin, shapeIndexDeltaSum / count, shapeIndexDeltaMax));
        System.out.println(String.format("distance min/avg/max: %f/%f/%f", distanceMin, distanceSum / count, distanceMax));
    }
}