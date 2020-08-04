use foofledb;



-- news
create procedure get_news(in userName varchar(30), out result boolean)
begin
    if(exists(select * from account where account.username = userName)) then
        select *
        from news
        where news.username = userName
        order by news.time desc;
        set result = true;
    else
        set result = false;
    end if;
end;




-- account
create procedure create_account(in uName varchar(30), in uPassword varchar(50), in sPhoneNumber varchar(20),
in firstName varchar(30), in lastName varchar(30), in nickName varchar(30), in nationalID varchar(20), in birthDate date, in pPhoneNumber varchar(20),
in defaultAccessStatus varchar(3), in uAddress varchar(512), out result boolean, out errorType varchar(100))
begin
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
end;





create procedure insert_special_access (in originUsername varchar(30), in requestedUsername varchar(30),in allowAccess varchar(6), out result boolean, out typeError varchar(100))
begin
    if (exists(select * from account where account.username = originUsername) and exists(select * from account where account.username = requestedUsername)) then
        insert into special_access
        values (originUsername, requestedUsername, allowAccess);
        set result = true;
    else
        set result = false;
        set typeError = 'OriginUsername or requestedUsername not exist!';
    end if;
end;



create procedure insert_last_account_sign_in(uName varchar(30))
begin
    insert into last_account_sign_in
    values (uName, current_timestamp);
end;



create procedure get_last_account_sign_in(out uName varchar(30))
begin
    select last_account_sign_in.username
    from last_account_sign_in
    limit 1
    into uName;
end;





create procedure sign_in(in userName varchar(30), in userPassword varchar(50), out result boolean, out typeError varchar(50))
begin
    if exists(select * from account where account.username = userName and account.user_password = md5(userPassword)) then
        set result = true;
        call insert_last_account_sign_in(userName);
    else
        set result = false;
        set typeError = 'username or password is incorrect';
    end if;
end;





create procedure get_my_account_information(in myUsername varchar(30), out result boolean)
begin
    select username, date_create, s_phone_number, first_name, last_name, nick_name, national_id, birth_date, p_phone_number, default_access_status, address
    from account
    where account.username = myUsername;
    set result = true;
end;




create procedure get_other_account_information(in myUsername varchar(30), in serachUsername varchar(30), out result boolean, out typeError varchar(100))
begin
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
end;






-- email

create procedure insert_senders(in emailID int, in senderUsername varchar(30), out result boolean, out typeError varchar(50))
begin
    if exists(select * from account where username = senderUsername) then
        insert into senders
        values (emailID,senderUsername, 0, 0);
        set result = true;
    else
        set result = false;
        set typeError = 'this username is not exist!';
    end if;
end;



create procedure insert_receivers(in emailID int, in receiverUsername varchar(30), out result boolean, out typeError varchar(50))
begin
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
end;



create procedure insert_receiversCC(in emailID int, in receiverCCUsername varchar(30), out result boolean, out typeError varchar(50))
begin
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
end;



create procedure send_email(in myUsername varchar(30), in receiver1Username varchar(30), in receiver2Username varchar(30), in receiver3Username varchar(30),
in receiverCC1Username varchar(30), in receiverCC2Username varchar(30), in receiverCC3Username varchar(30),
in emailSubject varchar(50), in emailContext varchar(512), out result boolean, out typeError varchar(100))
begin
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
end;






create procedure read_email(in myUsername varchar(30), in emailID int, out result boolean , out typeError varchar(50))
begin
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
end;



create procedure delete_email(in myUsername varchar(30), in emailID int, out result boolean, out typeError varchar(100))
begin
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
end;




create procedure get_inbox(in userName varchar(30), in pageNumber int)
begin
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
end;



create procedure get_sentBox(in userName varchar(30), in pageNumber int)
begin
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
end;






-- edit account and delete account
create procedure get_name(in userName varchar(30), out firsName varchar(30), out lastName varchar(30), out nickName varchar(30))
begin
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
end;



create procedure get_nationalID(in userName varchar(30), out nationalID varchar(20))
begin
    select national_id
    from account
    where account.username = userName
    into nationalID;
end;

create procedure get_birthDate(in userName varchar(30), out birthDate date)
begin
    select birth_date
    from account
    where account.username = userName
    into birthDate;
end;

create procedure get_phoneNumber(in userName varchar(30), out sPhoneNumber varchar(20), out pPhoneNumber varchar(20))
begin
    select s_phone_number
    from account
    where account.username = userName
    into sPhoneNumber;

    select p_phone_number
    from account
    where account.username = userName
    into pPhoneNumber;
end;

create procedure get_defaultAccessStatus(in userName varchar(30), out defaultAccessStatus varchar(3))
begin
    select default_access_status
    from account
    where account.username = userName
    into defaultAccessStatus;
end;

create procedure get_address(in userName varchar(30), out address varchar(30))
begin
    select address
    from account
    where account.username = userName
    into address;
end;

create procedure get_userPassword(in userName varchar(30), out userPassword varchar(50))
begin
    select user_password
    from account
    where account.username = userName
    into userPassword;
end;



create procedure edit_account(in myUsername varchar(30), in userPassword varchar(50), in fName varchar(30), in lName varchar(30), in nName varchar(30),
in nationalID varchar(20), in bDate date, in sPhoneNumber varchar(20), in pPhoneNumber varchar(20),
in defaultAccessStatus varchar(3), in uAddress varchar(100), out result boolean, out typeError varchar(50))
begin

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
end;



create procedure delete_account(in myUsername varchar(30), out result boolean, out typeError varchar(50))
begin
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
end;




