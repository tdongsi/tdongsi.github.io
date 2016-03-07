---
layout: post
title: "Mocking current date and time in Python"
date: 2016-01-27 17:36:53 -0800
comments: true
categories: 
- Python
- Automation
- Testing
---

### Calendar types

There are surprisingly many types of calendar. Some of them are:

1. **Regular Calendar**: regular solar calendar date range as we know. 
   * Example: January 01, 2006 to December 31, 2006.
1. [**Lunar Calendar**](https://en.wikipedia.org/wiki/Lunar_calendar): based on cycles of the lunar phases.
   * Example: January 29, 2006 to February 17, 2007.
   * A lunar year is defined as 12 lunations, which is about 354 days.
   * In every two or three years, a [thirteenth-month](https://en.wikipedia.org/wiki/Lunisolar_calendar) (intercalary month or leap month) is added to bring the calendar year into synchronisation with the solar year.
2. **Fiscal Calendar**: a company’s selected calendar date range for required SEC financial statement filing.
   * Example: August 01, 2005 to July 31, 2006 is my company's fiscal year 2006.
3. **Tax Calendar**: A number sequence representing weeks in a Tax year which begins right after the US Tax Day.
   * Example: April 16, 2005 to April 15, 2006.
4. **Retail Calendar**: also known as [4-4-5 Calendar](https://en.wikipedia.org/wiki/4%E2%80%934%E2%80%935_calendar) or 544 calendar. 544 describes the number of weeks for a given quarter. Each quarter begins with a 5 week "month", followed by 2 four week "months".
   * Example: July 31, 2005 to July 29, 2006.
   * Why? This calendar ensures all 4 quarters in a calendar year are equal. This allows comparing weekly data (e.g., retail sales) to the prior year without correcting for times when regular calendar weeks break across months or quarters.
   * How? It usually uses the same end month as the fiscal calendar and each retail week consists of Sunday through Saturday.
      * The retail year end is defined as "the last Saturday of the month at the fiscal year end".
      * If August 1st is Sunday, it is retail calendar's starting date. The Saturday July 31st is the last Saturday and end of the last retail year.
      * If August 1st is Monday, then Saturday July 30th is end of the last retail year, and July 31st is the start of the current retail year.
5. **ISO calendar**: provided in Python `datetime` module.
   * Example: January 02, 2006 to December 31, 2006.
   * The first week of an ISO year is the first (Gregorian/regular) calendar week of a year containing a Thursday.
   * Each week starts at Monday and ends at Sunday. 


Out of the above calendar types, retail calendar seems to have more complex rules. However, this calendar type is frequently used in industries like retail and manufacturing for ease of planning around it. 

### Mocking current time in Python

Due to retail calendar's desirable characteristics, we may have code that work with retail calendars in commercial applications eventually. 
I ended up working with a utility Python module for retail calendar with functions which return values based on current time/date. 
For example, a utility function to check if a given date is in the current 544 year works like this:

``` python Original version
def is_current_year_544(given_date):
    my_today = datetime.date.today()
    if year_start_544(my_today) <= given_date <= year_end_544(my_today):
        return "Y"
    else:
        return "N"
```

Some utility functions in that module are even more complicated than this example function. 
For those, I think calling `today` or `now` inside those functions is a bad design.
They are essentially another *variable* in those functions (i.e., when do you run?), and it is better to expose that variable as an input parameter. 
In addition, being able to specify what "today" or "now" value is will make automated unit testing easier. 
For example, I want to know how my Python programs work if it runs on a particular date, such as end of retail year July 29, 2006.
A probably better, more testable function would be something like this. 

``` python More desirable
def is_current_year_544(given_date, run_date = datetime.date.today()):
    if year_start_544(run_date) <= given_date <= year_end_544(run_date):
        return "Y"
    else:
        return "N"
```

However, in reality, you sometimes have to live with the original utility Python module. 
Then, the workaround for unit testing is to "mock" current date and time, i.e., overriding those returned by `today` and `now` methods with some specific values.
In Python, it can be done by using some mocking framework, such as illustrated [here](http://www.voidspace.org.uk/python/mock/examples.html#partial-mocking).
Fortunately, my life was made even easier with [`freezegun` library](https://github.com/spulec/freezegun). 
To install `freezegun` on Mac OSX, simply run 

``` plain   
pip install freezegun
```
 
Using this `freezegun` library, I can easily specify my "current date" as "July 29, 2006" by adding the following decorator with some string "2006-07-29" for that date.

``` python Unit test with mocking
    @freeze_time("2006-07-29")
    def test_year544_end(self):
        """
        Mock today() at 2006-07-29
        """
        self._verify_544_methods()
```

For full usage of `freezegun`, refer to its [quickstart guide](https://github.com/spulec/freezegun).
It should be noted that `freezegun` can mock `datetime` calls from other modules and it works great for testing with `datetime` calls. 
However, you might encounter some occasional failures in your unit tests when working with `time` module.
From my personal experience, in those cases, note that time zones must be accounted for when mocking with `time` module by specifying `tz_offset` in the decorator `freeze_time`.

### External Links

* [freeze_gun](https://github.com/spulec/freezegun)
* [Retail Calendar](https://en.wikipedia.org/wiki/4%E2%80%934%E2%80%935_calendar)
* [ISO Calendar](http://www.staff.science.uu.nl/~gent0113/calendar/isocalendar.htm)

