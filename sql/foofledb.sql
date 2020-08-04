-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 24, 2020 at 08:55 PM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `foofledb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_account` (IN `uName` VARCHAR(30), IN `uPassword` VARCHAR(50), IN `sPhoneNumber` VARCHAR(20), IN `firstName` VARCHAR(30), IN `lastName` VARCHAR(30), IN `nickName` VARCHAR(30), IN `nationalID` VARCHAR(20), IN `birthDate` DATE, IN `pPhoneNumber` VARCHAR(20), IN `defaultAccessStatus` VARCHAR(3), IN `uAddress` VARCHAR(512), OUT `result` BOOLEAN, OUT `errorType` VARCHAR(100))  begin
    if birthDate = '' then
            set birthDate = null;
        end if;

    if (length(uName) >= 6) and (length(uPassword) >= 6) and (not exists(select * from account where account.username = uName)) then
        insert into account(username, user_password, date_create, s_phone_number, first_name, last_name, nick_name, national_id, birth_date, p_phone_number, default_access_status, address)
        values (uName, md5(uPassword), current_timestamp,sPhoneNumber, firstName, lastName, nickName, nationalID, birthDate, pPhoneNumber, defaultAccessStatus, uAddress);
        set result = true;
    else
        set result = false;
        set errorType = 'length username or password < 6 or this username is exist.(choose another username!)';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_account` (IN `myUsername` VARCHAR(30), OUT `result` BOOLEAN, OUT `typeError` VARCHAR(50))  begin
    if exists(select * from account where username = myUsername) then
        if exists(select * from senders where sender_username = myUsername) then
            delete from senders
            where sender_username = myUsername;
        end if;
        if exists(select * from receivers where receiver_username = myUsername) then
            delete from receivers
            where receiver_username = myUsername;
        end if;
        if exists(select * from receiverscc where receiverCC_username = myUsername) then
            delete from receiverscc
            where receiverCC_username = myUsername;
        end if;
        if exists(select * from special_access where requested_username = myUsername) then
            delete from special_access
            where requested_username = myUsername;
        end if;
        if exists(select * from special_access where origin_username = myUsername) then
            delete from special_access
            where requested_username = myUsername;
        end if;
        if exists(select * from news where username = myUsername) then
            delete from news
            where username = myUsername;
        end if;
        if exists(select * from last_account_sign_in where username = myUsername) then
            delete from last_account_sign_in
            where username = myUsername;
        end if;
        if exists(select * from account where username = myUsername) then
            delete from account
            where username = myUsername;
        end if;

        set result = true;
    else
        set result = false;
        set typeError = 'this username is not exist!';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_email` (IN `myUsername` VARCHAR(30), IN `emailID` INT, OUT `result` BOOLEAN, OUT `typeError` VARCHAR(100))  begin
    if exists(select * from email where email_id = emailID) then
        if exists(select * from senders where email_id = emailID and sender_username = myUsername and senders.delete_status = 0) then
            update senders
            set delete_status = 1
            where email_id = emailID and sender_username = myUsername;
            set result = true;
        elseif exists(select * from receivers where email_id = emailID and receiver_username = myUsername and receivers.delete_status = 0) then
            update receivers
            set receivers.delete_status = 1
            where receivers.email_id = emailID and receivers.receiver_username = myUsername;
            set result = true;
        elseif exists(select * from receiverscc where receiverscc.email_id = emailID and receiverCC_username = myUsername and receiverscc.delete_status = 0) then
            update receiverscc
            set receiverscc.delete_status = 1
            where receiverscc.email_id = emailID and receiverscc.receiverCC_username = myUsername;
            set result = true;
        else
            set result = false;
            set typeError = 'this email id is not for this username! (or is deleted)';
        end if;
    else
        set result = false;
        set typeError = 'This email id is not exist!';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `edit_account` (IN `myUsername` VARCHAR(30), IN `userPassword` VARCHAR(50), IN `fName` VARCHAR(30), IN `lName` VARCHAR(30), IN `nName` VARCHAR(30), IN `nationalID` VARCHAR(20), IN `bDate` DATE, IN `sPhoneNumber` VARCHAR(20), IN `pPhoneNumber` VARCHAR(20), IN `defaultAccessStatus` VARCHAR(3), IN `uAddress` VARCHAR(100), OUT `result` BOOLEAN, OUT `typeError` VARCHAR(50))  begin

    call get_name(myUsername, @currentFName, @currentLName, @currentNName);
    call get_nationalID(myUsername, @currentNationalID);
    call get_birthDate(myUsername, @currentBirthDate);
    call get_phoneNumber(myUsername, @currentSPhoneNumber, @currentPPhoneNumber);
    call get_defaultAccessStatus(myUsername, @currentDefaultAccessStatus);
    call get_address(myUsername, @currentAddress);
    call get_userPassword(myUsername, @currentUserPassword);

    if fName = '-' then
        set fName = @currentFName;
    end if;
    if lName = '-' then
        set lName = @currentLName;
    end if;
    if nName = '-' then
        set nName = @currentNName;
    end if;
    if nationalID = '-' then
        set nationalID = @currentNationalID;
    end if;
    if bDate = '-' then
        set bDate = @currentBirthDate;
    end if;
    if sPhoneNumber = '-' then
        set sPhoneNumber = @currentSPhoneNumber;
    end if;
    if pPhoneNumber = '-' then
        set pPhoneNumber = @currentPPhoneNumber;
    end if;
    if defaultAccessStatus = '-' then
        set defaultAccessStatus = @currentDefaultAccessStatus;
    end if;
    if uAddress = '-' then
        set uAddress = @currentAddress;
    end if;
    if userPassword = '-' then
        set userPassword = @currentUserPassword;
    end if;


    if userPassword = @currentUserPassword then
        update account
        set s_phone_number = sPhoneNumber,first_name = fName, last_name = lName, nick_name = nName,
        national_id = nationalID, birth_date = bDate, p_phone_number = pPhoneNumber, default_access_status = defaultAccessStatus, address = uAddress
        where account.username = myUsername;
        set result = true;
    else
        if length(userPassword) >= 6 then
            update account
            set user_password = md5(userPassword), s_phone_number = sPhoneNumber,
            first_name = fName, last_name = lName, nick_name = nName,
            national_id = nationalID, birth_date = bDate, p_phone_number = pPhoneNumber, default_access_status = defaultAccessStatus, address = uAddress
            where account.username = myUsername;
            set result = true;
        else
            set result = false;
            set typeError = 'length new password < 6  and edit not saved!';
        end if;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_address` (IN `userName` VARCHAR(30), OUT `address` VARCHAR(30))  begin
    select address
    from account
    where account.username = userName
    into address;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_birthDate` (IN `userName` VARCHAR(30), OUT `birthDate` DATE)  begin
    select birth_date
    from account
    where account.username = userName
    into birthDate;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_defaultAccessStatus` (IN `userName` VARCHAR(30), OUT `defaultAccessStatus` VARCHAR(3))  begin
    select default_access_status
    from account
    where account.username = userName
    into defaultAccessStatus;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_inbox` (IN `userName` VARCHAR(30), IN `pageNumber` INT)  begin
    declare down int;
    declare up int;
    set down = (pageNumber-1)*10;
    set up = (pageNumber)*10;

    (select email.email_id, sender_username, subject, send_time, context, receiver_read_status as read_status
        from email, receivers, senders
        where receivers.delete_status = 0
        and receiver_username = userName
        and email.email_id = senders.email_id and email.email_id = receivers.email_id)
    union
    (select email.email_id, sender_username, subject, send_time, context, receiverCC_read_status as read_status
        from email, receiverscc, senders
        where receiverscc.delete_status = 0
        and receiverCC_username = userName
        and email.email_id = senders.email_id and email.email_id = receiverscc.email_id)
    order by send_time desc
    limit down, up;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_last_account_sign_in` (OUT `uName` VARCHAR(30))  begin
    select last_account_sign_in.username
    from last_account_sign_in
    limit 1
    into uName;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_my_account_information` (IN `myUsername` VARCHAR(30), OUT `result` BOOLEAN)  begin
    select username, date_create, s_phone_number, first_name, last_name, nick_name, national_id, birth_date, p_phone_number, default_access_status, address
    from account
    where account.username = myUsername;
    set result = true;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_name` (IN `userName` VARCHAR(30), OUT `firsName` VARCHAR(30), OUT `lastName` VARCHAR(30), OUT `nickName` VARCHAR(30))  begin
    select first_name
    from account
    where account.username = userName
    into firsName;

    select last_name
    from account
    where account.username = userName
    into lastName;

    select nick_name
    from account
    where account.username = userName
    into nickName;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_nationalID` (IN `userName` VARCHAR(30), OUT `nationalID` VARCHAR(20))  begin
    select national_id
    from account
    where account.username = userName
    into nationalID;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_news` (IN `userName` VARCHAR(30), OUT `result` BOOLEAN)  begin
    if(exists(select * from account where account.username = userName)) then
        select *
        from news
        where news.username = userName
        order by news.time desc;
        set result = true;
    else
        set result = false;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_other_account_information` (IN `myUsername` VARCHAR(30), IN `serachUsername` VARCHAR(30), OUT `result` BOOLEAN, OUT `typeError` VARCHAR(100))  begin
    declare allowAccess varchar(6);
    declare defaultAccessStatus varchar(3);
    if exists(select * from account where account.username = serachUsername) then
        if exists(select * from special_access where origin_username = serachUsername and requested_username = myUsername) then
            select allow_access
            from special_access
            where origin_username = serachUsername and requested_username = myUsername
            into allowAccess;
            if allowAccess = 'always' then
                select username, first_name, last_name, nick_name, national_id, birth_date, p_phone_number, default_access_status, address
                from account
                where username = serachUsername;
            else
                select '*' as username, '*' as first_name, '*' as last_name , '*' as nick_name, '*' as national_id, '*' as birth_date, '*' as  p_phone_number, '*' as default_access_status, '*' as address
                from account
                where username = serachUsername;
            end if;

            insert into news
            values (serachUsername, current_timestamp, concat('this username:', myUsername, 'want to get your account information and this account', allowAccess, 'was allowed access!'));
        else
            select default_access_status
            from account
            where username = serachUsername
            into defaultAccessStatus;
            if defaultAccessStatus = 'yes' then
                select username, first_name, last_name, nick_name, national_id, birth_date, p_phone_number, default_access_status, address
                from account
                where username = serachUsername;

                insert into news
                values (serachUsername, current_timestamp, concat('this username: ', myUsername, 'want to get your account information and this account was allowed access!'));
            else
                select '*' as username, '*' as first_name, '*' as last_name , '*' as nick_name, '*' as national_id, '*' as birth_date, '*' as  p_phone_number, '*' as default_access_status, '*' as address
                from account
                where username = serachUsername;

                insert into news
                values (serachUsername, current_timestamp, concat('this username: ', myUsername, 'want to get your account information and this account was allowed access!'));
            end if;
        end if;
    else
        set result = false;
        set typeError = 'searchUsername is not exist';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_phoneNumber` (IN `userName` VARCHAR(30), OUT `sPhoneNumber` VARCHAR(20), OUT `pPhoneNumber` VARCHAR(20))  begin
    select s_phone_number
    from account
    where account.username = userName
    into sPhoneNumber;

    select p_phone_number
    from account
    where account.username = userName
    into pPhoneNumber;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_sentBox` (IN `userName` VARCHAR(30), IN `pageNumber` INT)  begin
    declare down int;
    declare up int;
    set down = (pageNumber-1)*10;
    set up = (pageNumber)*10;

    select email.email_id, subject, send_time, context, sender_read_status
    from email, senders
    where email.email_id = senders.email_id
    and sender_username = userName
    and senders.delete_status = 0
    order by send_time desc
    limit down, up;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_userPassword` (IN `userName` VARCHAR(30), OUT `userPassword` VARCHAR(50))  begin
    select user_password
    from account
    where account.username = userName
    into userPassword;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_last_account_sign_in` (`uName` VARCHAR(30))  begin
    insert into last_account_sign_in
    values (uName, current_timestamp);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_receivers` (IN `emailID` INT, IN `receiverUsername` VARCHAR(30), OUT `result` BOOLEAN, OUT `typeError` VARCHAR(50))  begin
    if exists(select * from account where username = receiverUsername) then
        insert into receivers
        values (emailID, receiverUsername, 0, 0);
        set result = true;
    else
        set result = false;
        set typeError = 'this receiver username is not exist!';
    end if;
    if receiverUsername = '-' then
        set typeError = 'receiver username is null!';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_receiversCC` (IN `emailID` INT, IN `receiverCCUsername` VARCHAR(30), OUT `result` BOOLEAN, OUT `typeError` VARCHAR(50))  begin
    if exists(select * from account where username = receiverCCUsername) then
        insert into receiverscc
        values (emailID, receiverCCUsername, 0, 0);
        set result = true;
    else
        set result = false;
        set typeError = 'this receiver cc username is not exist';
    end if;
    if receiverCCUsername = '-' then
        set typeError = 'receiver cc username is null!';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_senders` (IN `emailID` INT, IN `senderUsername` VARCHAR(30), OUT `result` BOOLEAN, OUT `typeError` VARCHAR(50))  begin
    if exists(select * from account where username = senderUsername) then
        insert into senders
        values (emailID,senderUsername, 0, 0);
        set result = true;
    else
        set result = false;
        set typeError = 'this username is not exist!';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_special_access` (IN `originUsername` VARCHAR(30), IN `requestedUsername` VARCHAR(30), IN `allowAccess` VARCHAR(6), OUT `result` BOOLEAN, OUT `typeError` VARCHAR(100))  begin
    if (exists(select * from account where account.username = originUsername) and exists(select * from account where account.username = requestedUsername)) then
        insert into special_access
        values (originUsername, requestedUsername, allowAccess);
        set result = true;
    else
        set result = false;
        set typeError = 'OriginUsername or requestedUsername not exist!';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `read_email` (IN `myUsername` VARCHAR(30), IN `emailID` INT, OUT `result` BOOLEAN, OUT `typeError` VARCHAR(50))  begin
    if exists(select * from senders where email_id = emailID and sender_username = myUsername) then
        update senders
        set sender_read_status = 1
        where email_id = emailID and sender_username = myUsername;
        set result = true;
    elseif exists(select * from receivers where receivers.email_id = emailID and receiver_username = myUsername) then
        update receivers
        set receiver_read_status = 1
        where receivers.email_id = emailID and receiver_username = myUsername;
        set result = true;
    elseif exists(select * from receiverscc where receiverscc.email_id = emailID and receiverCC_username = myUsername) then
        update receiverscc
        set receiverCC_read_status = 1
        where receiverscc.email_id = emailID and receiverCC_username = myUsername;
        set result = true;
    else
        set result = 0;
        set typeError = 'this email id is not for this username!';
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_email` (IN `myUsername` VARCHAR(30), IN `receiver1Username` VARCHAR(30), IN `receiver2Username` VARCHAR(30), IN `receiver3Username` VARCHAR(30), IN `receiverCC1Username` VARCHAR(30), IN `receiverCC2Username` VARCHAR(30), IN `receiverCC3Username` VARCHAR(30), IN `emailSubject` VARCHAR(50), IN `emailContext` VARCHAR(512), OUT `result` BOOLEAN, OUT `typeError` VARCHAR(100))  begin
    declare emailID int;
    set emailID = 0;


    if (receiver1Username = '-') and (receiver2Username = '-') and (receiver3Username = '-') and (receiverCC1Username = '-')and (receiverCC2Username = '-') and (receiverCC3Username = '-') then
        set result = false;
        set typeError = 'This email has not receivers or receivers CC! (try again and choose receivers and receivers CC)';
    else
        if (exists(select * from account where username = receiver1Username) or (receiver1Username = '-'))
            and (exists(select * from account where username = receiver2Username) or (receiver2Username = '-'))
            and (exists(select * from account where username = receiver3Username) or (receiver3Username = '-')) then
                if (exists(select * from account where username = receiverCC1Username) or (receiverCC1Username = '-'))
                    and (exists(select * from account where username = receiverCC2Username) or (receiverCC2Username = '-'))
                    and (exists(select * from account where username = receiverCC3Username) or (receiverCC3Username = '-')) then

                    insert into email(subject, send_time, context)
                    values (emailSubject, current_timestamp, emailContext);

                    select email.email_id
                    from email
                    order by email_id desc
                    limit 1
                    into emailID;


                    call insert_senders(emailID, myUsername, @result, @typeError);

                    if  receiver1Username != '-' then
                        call insert_receivers(emailID, receiver1Username, @result, @typeError );
                    end if;

                    if receiver2Username != '-' then
                        call insert_receivers(emailID, receiver2Username,@result, @typeError);
                    end if;

                    if receiver3Username != '-' then
                        call insert_receivers(emailID, receiver3Username, @result, @typeError);
                    end if;

                    if receiverCC1Username != '-' then
                        call insert_receiversCC(emailID, receiverCC1Username, @result, @typeError);
                    end if;

                    if receiverCC2Username != '-' then
                        call insert_receiversCC(emailID, receiverCC2Username, @result, @typeError);
                    end if;

                    if receiverCC3Username != '-' then
                        call insert_receiversCC(emailID, receiverCC3Username, @result, @typeError);
                    end if;

                    set result = true;
                else
                    set result = false;
                    set typeError = 'at least one of receiversCC username is not exist';
                end if;
        else
        set result = False;
        set typeError = 'at least one of receivers username is not exist';
        end if;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sign_in` (IN `userName` VARCHAR(30), IN `userPassword` VARCHAR(50), OUT `result` BOOLEAN, OUT `typeError` VARCHAR(50))  begin
    if exists(select * from account where account.username = userName and account.user_password = md5(userPassword)) then
        set result = true;
        call insert_last_account_sign_in(userName);
    else
        set result = false;
        set typeError = 'username or password is incorrect';
    end if;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `account`
--

CREATE TABLE `account` (
  `username` varchar(30) NOT NULL,
  `user_password` varchar(50) DEFAULT NULL,
  `date_create` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `s_phone_number` varchar(20) DEFAULT NULL,
  `first_name` varchar(30) DEFAULT NULL,
  `last_name` varchar(30) DEFAULT NULL,
  `nick_name` varchar(30) DEFAULT NULL,
  `national_id` varchar(20) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `p_phone_number` varchar(20) DEFAULT NULL,
  `default_access_status` varchar(3) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `account`
--

INSERT INTO `account` (`username`, `user_password`, `date_create`, `s_phone_number`, `first_name`, `last_name`, `nick_name`, `national_id`, `birth_date`, `p_phone_number`, `default_access_status`, `address`) VALUES
('akbarrr', '13413048d65c36b50bbad2db6944c1d8', '2020-06-23 16:07:31', '', '', '', '', '', NULL, '', 'no', ''),
('amirmhdi', '36a020a051ae733d7110b3fa8b15b0cc', '2020-06-23 16:14:20', '', '', '', '', '', NULL, '', 'yes', ''),
('arminzd', 'fe881b3beab200577ccd36847d4feb1d', '2020-06-23 20:57:24', '', 'armin', 'zd', 'reza', '0022869', '0200-05-05', '09128216228', 'yes', NULL),
('arminzdzd', 'e61529a23f20e043b5978d7d7d5c0d1d', '2020-06-23 15:36:33', '', '', '', '', '', NULL, '', '', ''),
('rezakh', '34dc058fcd6de0396fdf82e09cf7a5f1', '2020-06-23 21:03:23', '091282162578', '', '', '', '', NULL, '', 'no', ''),
('rezakhandan', '2217b79780d3dc857c1263c6f0bdf667', '2020-06-24 18:48:09', '', '', '', '', '', NULL, '09126587458', 'yes', 'tehrannnn');

--
-- Triggers `account`
--
DELIMITER $$
CREATE TRIGGER `tr_create_account` AFTER INSERT ON `account` FOR EACH ROW insert into news(username, time, context)
    values (NEW.username, current_timestamp, 'you created an account successfully!')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_edit_account` AFTER UPDATE ON `account` FOR EACH ROW insert into news(username, time, context)
    values (new.username, current_timestamp, 'You edited account successfully!')
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `email`
--

CREATE TABLE `email` (
  `email_id` int(11) NOT NULL,
  `subject` varchar(50) DEFAULT NULL,
  `send_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `context` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `email`
--

INSERT INTO `email` (`email_id`, `subject`, `send_time`, `context`) VALUES
(1, 'test', '2020-06-23 16:09:32', 'test'),
(2, 'test', '2020-06-23 16:20:03', 'test'),
(3, 'testttt', '2020-06-23 20:58:08', 'testing'),
(4, 'test', '2020-06-23 21:04:36', 'test'),
(5, 'testttt akhar', '2020-06-24 18:49:43', 'testtt');

-- --------------------------------------------------------

--
-- Table structure for table `last_account_sign_in`
--

CREATE TABLE `last_account_sign_in` (
  `username` varchar(30) NOT NULL,
  `date_sign_in` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `last_account_sign_in`
--

INSERT INTO `last_account_sign_in` (`username`, `date_sign_in`) VALUES
('akbarrr', '2020-06-23 16:07:54'),
('amirmhdi', '2020-06-23 16:14:44'),
('amirmhdi', '2020-06-23 16:20:54'),
('amirmhdi', '2020-06-23 21:04:55'),
('arminzd', '2020-06-23 15:32:45'),
('arminzd', '2020-06-23 16:10:17'),
('arminzd', '2020-06-23 16:11:14'),
('arminzd', '2020-06-23 16:18:21'),
('arminzd', '2020-06-23 16:19:05'),
('arminzd', '2020-06-23 16:24:08'),
('arminzd', '2020-06-23 16:26:02'),
('arminzd', '2020-06-23 16:26:38'),
('arminzd', '2020-06-23 20:56:28'),
('rezakh', '2020-06-23 21:03:47'),
('rezakhandan', '2020-06-24 18:48:28'),
('rezakhandan', '2020-06-24 18:51:15');

--
-- Triggers `last_account_sign_in`
--
DELIMITER $$
CREATE TRIGGER `tr_sign_in` AFTER INSERT ON `last_account_sign_in` FOR EACH ROW insert into news(username, time, context)
    VALUES (NEW.username, current_timestamp, 'Sign in was successful!')
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `news`
--

CREATE TABLE `news` (
  `username` varchar(30) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `context` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `news`
--

INSERT INTO `news` (`username`, `time`, `context`) VALUES
('akbarrr', '2020-06-23 16:07:31', 'you created an account successfully!'),
('akbarrr', '2020-06-23 16:07:54', 'Sign in was successful!'),
('amirmhdi', '2020-06-23 16:14:20', 'you created an account successfully!'),
('amirmhdi', '2020-06-23 16:14:44', 'Sign in was successful!'),
('amirmhdi', '2020-06-23 16:20:03', 'You have new email.'),
('amirmhdi', '2020-06-23 16:20:54', 'Sign in was successful!'),
('amirmhdi', '2020-06-23 20:58:08', 'You have new email.'),
('amirmhdi', '2020-06-23 21:04:36', 'You have new email.'),
('amirmhdi', '2020-06-23 21:04:55', 'Sign in was successful!'),
('arminzd', '2020-06-23 15:32:35', 'you created an account successfully!'),
('arminzd', '2020-06-23 15:32:45', 'Sign in was successful!'),
('arminzd', '2020-06-23 16:09:32', 'You have new email.'),
('arminzd', '2020-06-23 16:10:17', 'Sign in was successful!'),
('arminzd', '2020-06-23 16:11:14', 'Sign in was successful!'),
('arminzd', '2020-06-23 16:18:21', 'Sign in was successful!'),
('arminzd', '2020-06-23 16:19:05', 'Sign in was successful!'),
('arminzd', '2020-06-23 16:24:08', 'Sign in was successful!'),
('arminzd', '2020-06-23 16:24:49', 'Email was deleted!'),
('arminzd', '2020-06-23 16:26:02', 'Sign in was successful!'),
('arminzd', '2020-06-23 16:26:38', 'Sign in was successful!'),
('arminzd', '2020-06-23 20:56:28', 'Sign in was successful!'),
('arminzd', '2020-06-23 20:57:24', 'You edited account successfully!'),
('arminzd', '2020-06-23 21:04:36', 'You have new email.'),
('arminzd', '2020-06-24 18:49:43', 'You have new email.'),
('arminzdzd', '2020-06-23 15:36:33', 'you created an account successfully!'),
('rezakh', '2020-06-23 21:03:23', 'you created an account successfully!'),
('rezakh', '2020-06-23 21:03:47', 'Sign in was successful!'),
('rezakh', '2020-06-23 21:05:16', 'this username: amirmhdiwant to get your account information and this account was allowed access!'),
('rezakhandan', '2020-06-24 18:48:09', 'you created an account successfully!'),
('rezakhandan', '2020-06-24 18:48:28', 'Sign in was successful!'),
('rezakhandan', '2020-06-24 18:51:15', 'Sign in was successful!');

-- --------------------------------------------------------

--
-- Table structure for table `receivers`
--

CREATE TABLE `receivers` (
  `email_id` int(11) NOT NULL,
  `receiver_username` varchar(30) NOT NULL,
  `receiver_read_status` int(11) DEFAULT NULL,
  `delete_status` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `receivers`
--

INSERT INTO `receivers` (`email_id`, `receiver_username`, `receiver_read_status`, `delete_status`) VALUES
(1, 'arminzd', 0, 1),
(2, 'amirmhdi', 0, 0),
(3, 'amirmhdi', 0, 0),
(4, 'arminzd', 0, 0),
(5, 'arminzd', 0, 0);

--
-- Triggers `receivers`
--
DELIMITER $$
CREATE TRIGGER `tr_delete_email_receivers` AFTER UPDATE ON `receivers` FOR EACH ROW if OLD.delete_status = 0 and NEW.delete_status = 1 then
        insert into news(username, time, context)
        values (new.receiver_username, current_timestamp, 'Email was deleted!');
    end if
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_send_email_receivers` AFTER INSERT ON `receivers` FOR EACH ROW insert into news(username, time, context)
    values(new.receiver_username, current_timestamp, 'You have new email.')
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `receiverscc`
--

CREATE TABLE `receiverscc` (
  `email_id` int(11) NOT NULL,
  `receiverCC_username` varchar(30) NOT NULL,
  `receiverCC_read_status` int(11) DEFAULT NULL,
  `delete_status` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `receiverscc`
--

INSERT INTO `receiverscc` (`email_id`, `receiverCC_username`, `receiverCC_read_status`, `delete_status`) VALUES
(4, 'amirmhdi', 0, 0);

--
-- Triggers `receiverscc`
--
DELIMITER $$
CREATE TRIGGER `tr_delete_email_receiversCC` AFTER UPDATE ON `receiverscc` FOR EACH ROW if OLD.delete_status = 0 and NEW.delete_status = 1 then
        insert into news(username, time, context)
        values (new.receiverCC_username, current_timestamp, 'Email was deleted!');
    end if
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_send_email_receiversCC` AFTER INSERT ON `receiverscc` FOR EACH ROW insert into news(username, time, context)
    values (new.receiverCC_username, current_timestamp, 'You have new email.')
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `senders`
--

CREATE TABLE `senders` (
  `email_id` int(11) NOT NULL,
  `sender_username` varchar(30) NOT NULL,
  `sender_read_status` int(11) DEFAULT NULL,
  `delete_status` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `senders`
--

INSERT INTO `senders` (`email_id`, `sender_username`, `sender_read_status`, `delete_status`) VALUES
(1, 'akbarrr', 1, 0),
(2, 'arminzd', 0, 0),
(3, 'arminzd', 1, 0),
(4, 'rezakh', 0, 0),
(5, 'rezakhandan', 1, 0);

--
-- Triggers `senders`
--
DELIMITER $$
CREATE TRIGGER `tr_delete_email_senders` AFTER UPDATE ON `senders` FOR EACH ROW if OLD.delete_status = 0 and NEW.delete_status = 1 then
        insert into news(username, time, context)
        values (new.sender_username, current_timestamp, 'Email was deleted!');
    end if
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `special_access`
--

CREATE TABLE `special_access` (
  `origin_username` varchar(30) NOT NULL,
  `requested_username` varchar(30) NOT NULL,
  `allow_access` varchar(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `special_access`
--

INSERT INTO `special_access` (`origin_username`, `requested_username`, `allow_access`) VALUES
('rezakh', 'arminzd', 'always');

-- --------------------------------------------------------

--
-- Table structure for table `test`
--

CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `name` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `test`
--

INSERT INTO `test` (`id`, `name`) VALUES
(1, 'armin');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `account`
--
ALTER TABLE `account`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `email`
--
ALTER TABLE `email`
  ADD PRIMARY KEY (`email_id`);

--
-- Indexes for table `last_account_sign_in`
--
ALTER TABLE `last_account_sign_in`
  ADD PRIMARY KEY (`username`,`date_sign_in`);

--
-- Indexes for table `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`username`,`time`);

--
-- Indexes for table `receivers`
--
ALTER TABLE `receivers`
  ADD PRIMARY KEY (`email_id`,`receiver_username`),
  ADD KEY `receiver_username` (`receiver_username`);

--
-- Indexes for table `receiverscc`
--
ALTER TABLE `receiverscc`
  ADD PRIMARY KEY (`email_id`,`receiverCC_username`),
  ADD KEY `receiverCC_username` (`receiverCC_username`);

--
-- Indexes for table `senders`
--
ALTER TABLE `senders`
  ADD PRIMARY KEY (`email_id`,`sender_username`),
  ADD KEY `sender_username` (`sender_username`);

--
-- Indexes for table `special_access`
--
ALTER TABLE `special_access`
  ADD PRIMARY KEY (`origin_username`,`requested_username`),
  ADD KEY `requested_username` (`requested_username`);

--
-- Indexes for table `test`
--
ALTER TABLE `test`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `email`
--
ALTER TABLE `email`
  MODIFY `email_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `test`
--
ALTER TABLE `test`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `last_account_sign_in`
--
ALTER TABLE `last_account_sign_in`
  ADD CONSTRAINT `last_account_sign_in_ibfk_1` FOREIGN KEY (`username`) REFERENCES `account` (`username`);

--
-- Constraints for table `news`
--
ALTER TABLE `news`
  ADD CONSTRAINT `news_ibfk_1` FOREIGN KEY (`username`) REFERENCES `account` (`username`);

--
-- Constraints for table `receivers`
--
ALTER TABLE `receivers`
  ADD CONSTRAINT `receivers_ibfk_1` FOREIGN KEY (`email_id`) REFERENCES `email` (`email_id`),
  ADD CONSTRAINT `receivers_ibfk_2` FOREIGN KEY (`receiver_username`) REFERENCES `account` (`username`);

--
-- Constraints for table `receiverscc`
--
ALTER TABLE `receiverscc`
  ADD CONSTRAINT `receiverscc_ibfk_1` FOREIGN KEY (`email_id`) REFERENCES `email` (`email_id`),
  ADD CONSTRAINT `receiverscc_ibfk_2` FOREIGN KEY (`receiverCC_username`) REFERENCES `account` (`username`);

--
-- Constraints for table `senders`
--
ALTER TABLE `senders`
  ADD CONSTRAINT `senders_ibfk_1` FOREIGN KEY (`email_id`) REFERENCES `email` (`email_id`),
  ADD CONSTRAINT `senders_ibfk_2` FOREIGN KEY (`sender_username`) REFERENCES `account` (`username`);

--
-- Constraints for table `special_access`
--
ALTER TABLE `special_access`
  ADD CONSTRAINT `special_access_ibfk_1` FOREIGN KEY (`origin_username`) REFERENCES `account` (`username`),
  ADD CONSTRAINT `special_access_ibfk_2` FOREIGN KEY (`requested_username`) REFERENCES `account` (`username`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
