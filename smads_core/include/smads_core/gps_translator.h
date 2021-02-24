#ifndef GPS_TRANSLATOR_H
#define GPS_TRANSLATOR_H
 
#include <eigen3/Eigen/Dense>
#include <eigen3/Eigen/Geometry>

using Eigen::Affine2d;
using Eigen::Rotation2Dd;
using Eigen::Vector2d;
using std::string;

class GPSTranslator
{
private:
    // Earth geoid parameters from WGS 84 system
    // https://en.wikipedia.org/wiki/World_Geodetic_System#A_new_World_Geodetic_System:_WGS_84
    // a = Semimajor (Equatorial) axis
    static constexpr double wgs_84_a = 6378137.0;
    // b = Semiminor (Polar) axis
    static constexpr double wgs_84_b = 6356752.314245;
    
    double gps_origin_longitude;
    double gps_origin_latitude;
    double map_orientation;
 
public:
    bool Load(const std::string& map, const std::string& maps_dir);
    void SetDate(int year, int month, int day);
 
    std::string GetMapFileFromName(const string& map, const string& maps_dir) {
	return maps_dir + "/" + map + "/" + map + ".gpsmap.txt";
    }
    Vector2d GpsToMetric(const double latitude, const double longitude);
    Vector2d MetricToGps(const double x, const double y);
};
#endif
