create database foofleDB;
use foofleDB;


create table account
(
    username varchar(30),
    user_password varchar(50),
    date_create timestamp,
    s_phone_number varchar(20),
    first_name varchar(30),
    last_name varchar(30),
    nick_name varchar(30),
    national_id varchar(20),
    birth_date date,
    p_phone_number varchar(20),
    default_access_status varchar(3) ,
    address varchar(100),
    primary key (username)
);



create table last_account_sign_in
(
    username varchar(30),
    date_sign_in timestamp,
    primary key (username, date_sign_in),
    foreign key (username) references account(username)
);



create table news
(
    username varchar(30),
    time timestamp,
    context varchar(200),
    primary key (username ,time),
    foreign key (username) references account(username)
);



create table special_access
(
    origin_username varchar(30),
    requested_username varchar(30),
    allow_access varchar(6),
    /* always or never*/
    primary key (origin_username, requested_username),
    foreign key (origin_username) references account(username),
    foreign key (requested_username) references account(username)
);





create table email
(
    email_id int auto_increment,
    subject varchar(50),
    send_time timestamp,
    context varchar(200),
    primary key (email_id)
);



create table senders
(
    email_id int,
    sender_username varchar(30),
    sender_read_status int,
    delete_status int,
    primary key (email_id, sender_username),
    foreign key (email_id) references email(email_id),
    foreign key (sender_username) references account(username)
);



create table receivers
(
    email_id int,
    receiver_username varchar(30),
    receiver_read_status int,
    delete_status int,
    primary key (email_id, receiver_username),
    foreign key (email_id) references email(email_id),
    foreign key (receiver_username) references account(username)
);



create table receiversCC
(
    email_id int,
    receiverCC_username varchar(30),
    receiverCC_read_status int,
    delete_status int,
    primary key (email_id, receiverCC_username),
    foreign key (email_id) references email(email_id),
    foreign key (receiverCC_username) references account(username)
);