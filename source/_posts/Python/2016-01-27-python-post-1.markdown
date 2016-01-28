---
layout: post
title: "Mocking current time in Python"
date: 2016-01-27 17:36:53 -0800
comments: true
categories: 
- Python
- Mocking
---

### Calendar types

There are surprisingly many types of calendar.

1. **Regular Calendar**: regular solar calendar date range as we know. 
   * Example: January 01, 2006 to December 31, 2006.
2. **Fiscal Calendar**: a company’s selected calendar date range for required SEC financial statement filing.
   * Example: August 01, 2005 to July 31, 2006 is my company's fiscal year 2006.
3. **Tax Calendar**: A number sequence representing weeks in a Tax year which begins right after the US Tax Day.
   * Example: April 16, 2005 to April 15, 2006.
4. **Retail Calendar**: also known as [4-5-5 Calendar](https://en.wikipedia.org/wiki/4%E2%80%934%E2%80%935_calendar) or 544 calendar. 544 describes the number of weeks for a given quarter. Each quarter begins with a 5 week "month", followed by 2 four week "months".
   * Example: July 31, 2005 to July 29, 2006.
   * Why? This calendar ensures all 4 quarters in a calendar year are equal. This allows comparing weekly data (e.g., retail sales) to the prior year without correcting for times when regular calendar weeks break across months or quarters.
   * How? It usually uses the same end month as the fiscal calendar and each retail week consists of Sunday through Saturday.
      * The retail year end is defined as "the last Saturday of the month at the fiscal year end".
      * If August 1st is Sunday, it is retail calendar's starting date. The Satuday July 31st is the last Saturday and end of the last retail year.
      * If August 1st is Monday, then Saturday July 30th is end of the last retail year, and July 31st is the start of the current retail year.
5. **ISO calendar**: provided in Python `datetime` module.
   * Example: January 02, 2006 to December 31, 2006.
   * The first week of an ISO year is the first (Gregorian/regular) calendar week of a year containing a Thursday.
   * Each week starts at Monday and ends at Sunday. 


Out of the above calendar types, retail calendar has the seemingly more complex rules. However, this calendar type is frequently used in industries like retail and manufacturing for ease of planning around it. 

### Mocking current time in Python

Due to retail calendar's desirable characteristics, we may have code that work with retail calendars eventually. 
I ended up working with a utility Python module with functions which return values based on current time/date. 
For example, a utility function is to check a given date is in the current 544 year or quarter.

``` python Original version
def is_current_year_544(given_date):
    my_today = datetime.date.today()
    if year_start_544(my_today) <= given_date <= end544(my_today):
        return "Y"
    else:
        return "N"
```

A probably better, more testable overloaded method would be something list this:

``` python More desirable
def is_current_year_544(given_date, my_today = datetime.date.today()):
    if year_start_544(my_today) <= given_date <= year_end_544(my_today):
        return "Y"
    else:
        return "N"
```



### External Links

* [Retail Calendar](https://en.wikipedia.org/wiki/4%E2%80%934%E2%80%935_calendar)
* [ISO Calendar](http://www.staff.science.uu.nl/~gent0113/calendar/isocalendar.htm)

