@isTest
private class SFSUtilTest {
	
	@isTest static void testStateCode() {
		// Implement test code
		String stateCode = SFSUtil.getStateCode('Vermont');
		system.assertEquals('VT',stateCode);
	}
	
	@isTest static void testStateName() {
		String stateName = SFSUtil.getStateName('PA');
		system.assertEquals('Pennsylvania',stateName);

	}
	
}