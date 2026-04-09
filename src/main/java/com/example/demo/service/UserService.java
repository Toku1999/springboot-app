package com.example.demo.service;

import com.example.demo.model.User;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class UserService {

    private List<User> users = new ArrayList<>();

    public List<User> getUsers() {
        return users;
    }

    public User addUser(User user) {
        users.add(user);
        return user;
    }
}
