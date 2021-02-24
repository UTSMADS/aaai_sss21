//========================================================================
//  This software is free: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License Version 3,
//  as published by the Free Software Foundation.
//
//  This software is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  Version 3 in the file COPYING that came with this distribution.
//  If not, see <http://www.gnu.org/licenses/>.
//========================================================================
/*!
\file    gps_translator.cc
\brief   Translate from GPS to map coordinates
\author  Joydeep Biswas, (C) 2020
\author   Maxwell Svetlik
*/
//========================================================================

#include <stdio.h>

#include <cmath>
#include <string>

#include "sensor_msgs/NavSatFix.h"
#include "geometry_msgs/PointStamped.h"
#include "smads_core/gps_translator.h"
#include "helpers.h"
#include "math_util.h"

using Eigen::Affine2d;
using Eigen::Rotation2Dd;
using Eigen::Vector2d;
using std::string;

using namespace math_util;
bool GPSTranslator::Load(const std::string& map, const std::string& maps_dir) {
    const string file = GetMapFileFromName(map, maps_dir);
    printf("Opening file: %s", file.c_str());
    ScopedFile fid(file, "r", true);
    if (fid() == nullptr) return false;
    if (fscanf(fid(), "%lf, %lf, %lf", &gps_origin_latitude, 
        &gps_origin_longitude, &map_orientation) != 3) {
      return false;
    }
    printf("Map origin: %12.8lf, %12.8lf\n", gps_origin_latitude, gps_origin_longitude);
    return true;
}

Vector2d GPSTranslator::GpsToMetric(const double latitude, const double longitude) {
    const double theta = DegToRad(latitude);
    const double c = std::cos(theta);
    const double s = std::sin(theta);
    const double r = sqrt(Sq(wgs_84_a * wgs_84_b) / (Sq(c * wgs_84_b) + Sq(s * wgs_84_a)));
    const double dlat = DegToRad(latitude - gps_origin_latitude);
    const double dlong = DegToRad(longitude - gps_origin_longitude);
    const double r1 = r * c;
    const double x = r1 * dlong;
    const double y = r * dlat;
    return Rotation2Dd(map_orientation) * Vector2d(x, y);
}

Vector2d GPSTranslator::MetricToGps(const double x, const double y) {
    Vector2d rot = Rotation2Dd(map_orientation).inverse() * Vector2d(x,y);
    const double theta = DegToRad(gps_origin_latitude);
    const double c = std::cos(theta);
    const double s = std::sin(theta);
    const double r = sqrt(Sq(wgs_84_a * wgs_84_b) / (Sq(c * wgs_84_b) + Sq(s * wgs_84_a)));
    const double r1 = r * c;
    const double dlat = rot.y() / r;
    const double dlong = rot.x() / r1;
    const double longitude = (gps_origin_longitude + RadToDeg(dlong));
    const double latitude = (gps_origin_latitude + RadToDeg(dlat));
    return Vector2d(latitude, longitude);
}
