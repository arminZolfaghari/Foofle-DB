use foofledb;



create trigger tr_create_account after insert on account
    for each row
    insert into news(username, time, context)
    values (NEW.username, current_timestamp, 'you created an account successfully!');



create trigger tr_sign_in after insert on last_account_sign_in
    for each row
    insert into news(username, time, context)
    VALUES (NEW.username, current_timestamp, 'Sign in was successful!');



create trigger tr_edit_account after update on account
    for each row
    insert into news(username, time, context)
    values (new.username, current_timestamp, 'You edited account successfully!');



create trigger tr_send_email_receivers after insert on receivers
    for each row
    insert into news(username, time, context)
    values(new.receiver_username, current_timestamp, 'You have new email.');




create trigger tr_send_email_receiversCC after insert on receiverscc
    for each row
    insert into news(username, time, context)
    values (new.receiverCC_username, current_timestamp, 'You have new email.');



create trigger tr_delete_email_senders after update on senders
    for each row
    if OLD.delete_status = 0 and NEW.delete_status = 1 then
        insert into news(username, time, context)
        values (new.sender_username, current_timestamp, 'Email was deleted!');
    end if;



create trigger tr_delete_email_receivers after update on receivers
    for each row
    if OLD.delete_status = 0 and NEW.delete_status = 1 then
        insert into news(username, time, context)
        values (new.receiver_username, current_timestamp, 'Email was deleted!');
    end if;



create trigger tr_delete_email_receiversCC after update on receiverscc
    for each row
    if OLD.delete_status = 0 and NEW.delete_status = 1 then
        insert into news(username, time, context)
        values (new.receiverCC_username, current_timestamp, 'Email was deleted!');
    end if;


