package edu.utexas.hcrl.SDMS.sdmsBackend.models.domain;

public class StatusTimestamp {
    private double seconds;
    private double milliseconds;

    public StatusTimestamp() {
    }


    public StatusTimestamp(double seconds, double milliseconds) {
        this.seconds = seconds;
        this.milliseconds = milliseconds;
    }

    public double getSeconds() {
        return seconds;
    }

    public void setSeconds(double seconds) {
        this.seconds = seconds;
    }

    public double getMilliseconds() {
        return milliseconds;
    }

    public void setMilliseconds(double milliseconds) {
        this.milliseconds = milliseconds;
    }

    public boolean isAfter(StatusTimestamp other){
        if (other.seconds < this.seconds) {
            return true;
        }
        return other.seconds == this.seconds && other.milliseconds < this.milliseconds;
    }
}
