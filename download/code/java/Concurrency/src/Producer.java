package my.practice.concurrency;

public interface Producer extends Runnable {
	
	/**
	 * Add some item into a common item queue
	 */
	public void produce();
	
	/**
	 * Use Counter as an item queue
	 * 
	 * @param queue
	 */
	public void useQueue(Counter queue);

}
