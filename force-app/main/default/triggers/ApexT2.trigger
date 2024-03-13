trigger ApexT2 on Account (before update)
{
    Account o=Trigger.old[0];
    Account n=Trigger.new[0];
    System.debug('o '+o);
    System.debug('n '+n);
}