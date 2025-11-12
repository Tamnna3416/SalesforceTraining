trigger AccountDefaultRating on Account (before insert) {
    for (Account a : Trigger.new) {
        if (a.Rating == null) {
            a.Rating = 'Cold';
        }
    }
}