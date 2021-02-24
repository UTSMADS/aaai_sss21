package edu.utexas.hcrl.SDMS.sdmsBackend.repositories;

import edu.utexas.hcrl.SDMS.sdmsBackend.enums.TripStatus;
import edu.utexas.hcrl.SDMS.sdmsBackend.models.domain.Trip;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TripRepository extends CrudRepository<Trip, Integer> {
    @Query("select t from Trip t where t.spotManufacturerID = ?1 and t.tripStatus <> 'complete' and t.tripStatus <> 'cancelled' and t.isActive = true")
    Optional<Trip> getCurrentTripForSpot(int manufacturerId);

    @Query("select t from Trip t where t.spotManufacturerID = ?1 order by t.startTime DESC")
    Iterable<Trip> getAllTripsForSpot(int manufacturerID);

    @Query("select t from Trip t where t.userID = ?1 order by t.startTime DESC")
    Iterable<Trip> getAllTripsForUser(int userID);

    @Query("select t from Trip t where t.isActive = true and t.userID = ?1 and t.tripStatus <> 'complete' order by t.startTime DESC")
    Iterable<Trip> getActiveTripForCustomer(int userID);

    @Query("select t from Trip t where t.isActive = true and (t.tripStatus = 'enroute' or t.tripStatus = 'dropoff') and t.payloadContent <> 'Returning Home' order by t.startTime ASC")
    Iterable<Trip> getAllActiveTrips();

    @Query("select t from Trip t where t.isActive = true and (t.tripStatus = 'processing' or t.tripStatus = 'requested') order by t.startTime ASC")
    Iterable<Trip> getTripsToBeSent();

    @Query("select t from Trip t where t.isActive = true and t.tripStatus = ?1 order by t.startTime ASC")
    Iterable<Trip> getAllQueuedTrips(TripStatus tripStatus);

    @Query("select t from Trip t where (t.tripStatus = 'enroute' or t.tripStatus = 'returningHome') and t.payloadContent = 'Returning Home' order by t.startTime ASC")
    Iterable<Trip> getAllReturningHomeTrips();
}